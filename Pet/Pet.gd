extends Control


onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var action_switch_timer: Timer = $ActionSwitchTimer
onready var action_on_wall_switch_timer: Timer = $ActionOnWallSwitchTimer
var child_window: Node2D = null setget add_child_window

enum State { RELEASED, DRAGGING, ACTION, ACTION_ON_WALL }
enum Action { IDLE, WALK, RUN }
enum ActionOnWall { GRAB, CLIMB, JUMP }

#constant
const walk_speed := 100
const run_speed := 200
const climb_speed := 50
const jump_speed := 200
var screen_size := OS.get_screen_size()
const pet_size := Vector2(135, 95)
const pet_size_on_wall := Vector2(65, 115)
var gravity :float = ProjectSettings.get("physics/2d/default_gravity")

#variable
var state setget set_state
var action setget set_action
var action_on_wall setget set_action_on_wall
var mood := 40 setget set_mood
var emotion setget ,get_emotion
var velocity := Vector2.ZERO
var click_pos := Vector2.ZERO
var direction := 1

enum Wall { NOT=0, LEFT=-1, RIGHT=1 }
var on_wall = Wall.NOT


func _ready() -> void:
	randomize()
	get_tree().connect("files_dropped", self, "_on_file_drag")
	self.state = State.RELEASED
	OS.window_size = pet_size
	animated_sprite.position = pet_size / 2
	self.child_window = preload("res://Pet/Weather.tscn").instance()
	
	

func _physics_process(delta: float) -> void:
	match self.state:
		State.DRAGGING:
			if OS.window_position.x + get_global_mouse_position().x <= 1:
				if on_wall != Wall.LEFT:
					self.on_wall = Wall.LEFT
			elif OS.window_position.x + get_global_mouse_position().x >= screen_size.x - 1:
				if on_wall != Wall.RIGHT:
					self.on_wall = Wall.RIGHT
			else:
				on_wall = Wall.NOT
				
			#to RELEASED
			if not Input.is_action_pressed("click"):
				self.state = State.RELEASED
			else:
				OS.window_position += get_global_mouse_position() - click_pos

		State.RELEASED:
			#to DRAGGING
			if Input.is_action_just_pressed("click"):
				self.state = State.DRAGGING
			#to ACTION_ON_WALL
			elif on_wall != Wall.NOT:
				self.state = State.ACTION_ON_WALL
			#to ACTION
			elif OS.window_position.y + OS.window_size.y >= screen_size.y:
				self.state = State.ACTION
			else:
				velocity.y += gravity * delta
				OS.window_position += velocity * delta
				
		State.ACTION:
			if OS.window_position.x <= 1:
				if on_wall != Wall.LEFT:
					self.on_wall = Wall.LEFT
			elif OS.window_position.x + pet_size.x >= screen_size.x - 1:
				if on_wall != Wall.RIGHT:
					self.on_wall = Wall.RIGHT
			else:
				on_wall = Wall.NOT
				
			#to DRAGGING
			if Input.is_action_just_pressed("click"):
				self.state = State.DRAGGING
			#near wall
			elif on_wall != Wall.NOT:
				self.state = State.ACTION_ON_WALL
			else:
				OS.window_position += velocity * delta
		State.ACTION_ON_WALL:
			if Input.is_action_just_pressed("click"):
				self.state = State.DRAGGING
			#when action_on_wall is jump, state will become RELEASED
			else:
				OS.window_position += velocity * delta


func set_state(new_state) -> void:
	match state:
		State.ACTION:
			action_switch_timer.stop()
		State.ACTION_ON_WALL:
			action_on_wall_switch_timer.stop()
			OS.window_size = pet_size
			animated_sprite.position = pet_size / 2

	match new_state:
		State.RELEASED:
			if state != State.ACTION_ON_WALL:
				animation_player.play("release")
		State.DRAGGING:
			self.mood -= 5
			velocity = Vector2.ZERO
			click_pos = get_local_mouse_position()
			animation_player.play("drag")
		State.ACTION:
			if state == State.RELEASED:
				OS.window_position.y = screen_size.y - OS.window_size.y
				velocity.y = 0
				animation_player.play("land") # will set action to idle
		State.ACTION_ON_WALL:
			if child_window != null:
				child_window.queue_free()
				remove_child(child_window)
				child_window = null
			OS.window_size = pet_size_on_wall
			animated_sprite.position = pet_size_on_wall / 2
			match on_wall:
				Wall.LEFT:
					animated_sprite.flip_h = true
					OS.window_position.x = 0
				Wall.RIGHT:
					animated_sprite.flip_h = false
					OS.window_position.x = screen_size.x - pet_size_on_wall.x
			match state:
				State.RELEASED:
					self.action_on_wall = ActionOnWall.GRAB
				State.ACTION:
					self.action_on_wall = ActionOnWall.CLIMB

	state = new_state


func set_action(new_action) -> void:
	match new_action:
		Action.IDLE:
			velocity = Vector2.ZERO
			action_switch_timer.start(6.4 - mood / 10.0)
			animation_player.play("idle")
		Action.WALK:
			self.mood += 1
			if randi() % 2 > 0:
				direction = -direction
				animated_sprite.flip_h = not animated_sprite.flip_h
			velocity = Vector2.RIGHT * walk_speed * direction
			action_switch_timer.start(4.8)
			animation_player.play("walk")
		Action.RUN:
			self.mood += 3
			if randi() % 4 > 0:
				direction = -direction
				animated_sprite.flip_h = not animated_sprite.flip_h
			velocity = Vector2.RIGHT * run_speed * direction
			action_switch_timer.start(2.4) # 2 to 0
			animation_player.play("run")
			
	action = new_action


func set_action_on_wall(new_action_on_wall) -> void:
	match new_action_on_wall:
		ActionOnWall.GRAB:
			velocity = Vector2.ZERO
			action_on_wall_switch_timer.start(1.2 - mood / 50.0)
			animation_player.play("grab")
		ActionOnWall.CLIMB:
			self.mood += 1
			velocity = Vector2.UP * climb_speed
			action_on_wall_switch_timer.start(1 + mood / 20.0)
			animation_player.play("climb")
		ActionOnWall.JUMP:
			self.mood += 10
			match on_wall:
				Wall.LEFT:
					animated_sprite.flip_h = false
					direction = 1
				Wall.RIGHT:
					animated_sprite.flip_h = true
					direction = -1
			velocity = Vector2.LEFT * jump_speed * on_wall
			animation_player.play("jump_from_grab")
			on_wall = Wall.NOT
			self.state = State.RELEASED

	action_on_wall = new_action_on_wall


func set_mood(new_mood) -> void:
	var pre_emotion = self.emotion
	if new_mood > 50:
		mood = 50
	elif new_mood < 0:
		mood = 0
	else:
		mood = new_mood
	if self.emotion != pre_emotion:
		self.child_window = preload("res://Pet/Expression.tscn").instance().new(self.emotion)


func get_emotion() -> String:
	if mood >= 40:
		return "happy"
	elif mood >= 20:
		return "sad"
	else:
		return "angry"


func _on_ActionSwitchTimer_timeout() -> void:
	match action:
		Action.IDLE:
			match randi() % 2 + mood / 20:
				0, 1:
					self.action = Action.WALK
				_:
					self.action = Action.RUN
		Action.WALK:
			match randi() % 3 + mood / 20:
				0, 1 ,2:
					self.action = Action.IDLE
				_:
					self.action = Action.RUN
		Action.RUN:
			match randi() % 5 + mood / 10:
				0, 1, 2, 3, 4:
					self.action = Action.IDLE
				_:
					self.action = Action.WALK


func _on_ActionOnWallSwitchTimer_timeout() -> void:
	match action_on_wall:
		ActionOnWall.CLIMB:
			self.action_on_wall = ActionOnWall.GRAB
		ActionOnWall.GRAB:
			if OS.window_position.y / screen_size.y < randf():
				self.action_on_wall = ActionOnWall.JUMP
			else:
				self.action_on_wall = ActionOnWall.CLIMB


func _on_file_drag(files: PoolStringArray, _screen) -> void:
	for i in range(files.size()):
		var file_path := files[i]
		var folder := file_path.get_base_dir()
		var file := file_path.get_file()
		var file_extension := file_path.get_extension().to_lower()
		
		
		if file_extension in ["zip", "rar", "7z"]:
			OS.execute("powershell.exe", ["-Command", "./7-Zip/7z.exe", "x", file_path, "-o"+folder], false)
		else:
			var output = []
			OS.execute("powershell.exe", ["-Command", "Test-Path", '""%s""' % file_path], true, output)
			print(output.front())
			
			if "True" in output.front():
				OS.execute("powershell.exe", ["-Command", "cd", '""%s""' % file_path, ";", "mv", "*.*", ".."], false)
			
			OS.execute("powershell.exe", ["-Command", "./delete_file.ps1", '""%s""' % file_path], false)
		


func add_child_window(node: Node2D) -> void:
	print(OS.window_position)
	if child_window != null:
		remove_child_window()
	var rect = {"start":Vector2(), "end":Vector2()}
	var current_pet_size:Vector2
	if on_wall:
		current_pet_size = pet_size_on_wall
	else:
		current_pet_size = pet_size
	rect.start = -current_pet_size / 2
	rect.end = current_pet_size / 2
	
	add_child(node)
	if node.position.x - node.size.x / 2 < rect.start.x:
		rect.start.x = node.position.x - node.size.x / 2
	if node.position.x + node.size.x / 2 > rect.end.x:
		rect.end.x = node.position.x + node.size.x / 2
	if node.position.y - node.size.y / 2 < rect.start.y:
		rect.start.y = node.position.y - node.size.y / 2
	if node.position.y + node.size.y / 2 > rect.end.y:
		rect.end.y = node.position.y + node.size.y / 2
		
	OS.window_size = rect.end - rect.start
	if on_wall:
		var offset :int = (OS.window_size.x - current_pet_size.x) * on_wall
		OS.window_position.x -= offset
		animated_sprite.position.x += offset
	else:
		var offset := OS.window_size.y - current_pet_size.y
		OS.window_position.y -= offset
		animated_sprite.position.y += offset
	node.position += animated_sprite.position

	child_window = node
	print(OS.window_position)

func remove_child_window() -> void:
	if child_window != null:
		child_window.queue_free()
		remove_child(child_window)
		child_window = null
		if on_wall:
			OS.window_position.x += (OS.window_size.x - pet_size_on_wall.x) * on_wall
			OS.window_size = pet_size_on_wall
			animated_sprite.position = pet_size_on_wall / 2
		else:
			OS.window_position.y += OS.window_size.y - pet_size.y
			OS.window_size = pet_size
			animated_sprite.position = pet_size / 2
