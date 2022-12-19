extends Control
class_name Pet
#enum PetType {cat, }
enum PetVariety {black, brown, white}
export(PetVariety) var pet_variety = PetVariety.white

signal change_mood

onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var action_switch_timer: Timer = $ActionSwitchTimer
onready var action_on_wall_switch_timer: Timer = $ActionOnWallSwitchTimer
onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
var child_window: Node2D = null setget add_child_window

enum State { RELEASED, DRAGGING, ACTION, ACTION_ON_WALL, STOP}
enum Action { IDLE, WALK, RUN }
enum ActionOnWall { GRAB, CLIMB, JUMP }
enum EmotionalThreshold {LOW, MEDIUM, HIGH}
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
var happy_mood := 40
var sad_mood := 20
export(EmotionalThreshold) var emotional_threshold = EmotionalThreshold.LOW setget set_emotional_threshold
var emotion setget ,get_emotion
var velocity := Vector2.ZERO
var click_pos := Vector2.ZERO

enum Wall { NOT=0, LEFT=-1, RIGHT=1 }
var on_wall = Wall.NOT

func _ready() -> void:
	set_variety(pet_variety)
	randomize()
	get_tree().connect("files_dropped", self, "_on_file_drag")
	connect("change_mood", $"../Tray", "OnChangeMood")
	self.state = State.RELEASED
	OS.window_size = pet_size
	collision_shape_2d.shape.extents = pet_size / 2
	collision_shape_2d.position = pet_size / 2
	animated_sprite.position = pet_size / 2
	self.child_window = preload("res://Pet/Weather.tscn").instance()


func _physics_process(delta: float) -> void:
#	print(get_global_rect().has_point(get_global_mouse_position()))
#	开启事件
	if Input.is_action_just_pressed("control") and child_window == null and state != State.STOP:
		self.child_window = preload("res://Pet/Expression.tscn").instance().new("ballgame")

	match self.state:
		State.STOP:
			pass
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
			#when action_on_wall is ActionOnWall.JUMP, state will become State.RELEASED
			else:
				OS.window_position += velocity * delta


func set_state(new_state) -> void:
	match state:
		State.ACTION:
			action_switch_timer.stop()
		State.ACTION_ON_WALL:
			action_on_wall_switch_timer.stop()
			OS.window_size = pet_size
			collision_shape_2d.shape.extents = pet_size / 2
			collision_shape_2d.position = pet_size / 2
			animated_sprite.position = pet_size / 2
		State.STOP:
#			self.remove_child_window()
			pass

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
			collision_shape_2d.shape.extents = pet_size_on_wall / 2
			collision_shape_2d.position = pet_size_on_wall / 2
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
				animated_sprite.flip_h = not animated_sprite.flip_h
			velocity = Vector2.RIGHT * walk_speed * -(int(animated_sprite.flip_h) * 2 - 1)
			action_switch_timer.start(4.8)
			animation_player.play("walk")
		Action.RUN:
			self.mood += 3
			if randi() % 4 > 0:
				animated_sprite.flip_h = not animated_sprite.flip_h
			velocity = Vector2.RIGHT * run_speed * -(int(animated_sprite.flip_h) * 2 - 1)
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
				Wall.RIGHT:
					animated_sprite.flip_h = true
			velocity = Vector2.LEFT * jump_speed * on_wall
			animation_player.play("jump")
			on_wall = Wall.NOT
			self.state = State.RELEASED

	action_on_wall = new_action_on_wall


func set_mood(new_mood) -> void:
	emit_signal("change_mood", new_mood)
	var pre_emotion = self.emotion
	if new_mood > happy_mood*2:
		mood = happy_mood*2
	elif new_mood < 0:
		mood = 0
	else:
		mood = new_mood
	if self.emotion != pre_emotion:
		self.child_window = preload("res://Pet/Expression.tscn").instance().new(self.emotion)


func get_emotion() -> String:
	if mood >= happy_mood:
		return "happy"
	elif mood >= sad_mood:
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
			if "True" in output.front():
				OS.execute("powershell.exe", ["-Command", "cd", '""%s""' % file_path, ";", "mv", "*.*", ".."], false)
			OS.execute("powershell.exe", ["-Command", "./delete_file.ps1", '""%s""' % file_path], false)
		


func add_child_window(node: Node2D) -> void:
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
	collision_shape_2d.shape.extents = OS.window_size / 2
	collision_shape_2d.position = OS.window_size / 2
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
		if self.state ==State.STOP:
			pass
		elif on_wall:
			OS.window_position.x += (OS.window_size.x - pet_size_on_wall.x) * on_wall
			OS.window_size = pet_size_on_wall
			collision_shape_2d.shape.extents = pet_size_on_wall / 2
			collision_shape_2d.position = pet_size_on_wall / 2
			animated_sprite.position = pet_size_on_wall / 2
		else:
			OS.window_position.y += OS.window_size.y - pet_size.y
			OS.window_size = pet_size
			collision_shape_2d.shape.extents = pet_size / 2
			collision_shape_2d.position = pet_size / 2
			animated_sprite.position = pet_size / 2

func set_emotional_threshold(new_emotional_threshold):
	match new_emotional_threshold:
		EmotionalThreshold.LOW:
			mood = 20
			happy_mood = 20
			sad_mood = 10
		EmotionalThreshold.MEDIUM:
			mood = 40
			happy_mood = 40
			sad_mood = 20
		EmotionalThreshold.HIGH:
			mood = 60
			happy_mood = 60
			sad_mood = 30
	emotional_threshold = new_emotional_threshold
			
func set_variety(new_variety) -> void:
	pet_variety = new_variety
	var variety :String = PetVariety.keys()[pet_variety]
	animated_sprite.frames.clear_all()
	
	animated_sprite.frames.add_animation("jump")
	animated_sprite.frames.set_animation_loop("jump", false)
	animated_sprite.frames.set_animation_speed("jump", 8)
	for i in range(3):
		animated_sprite.frames.add_frame("jump", load("res://Assets/cat/"+variety+"_fall_from_grab_8fps/"+str(i)+".png"))
		
	animated_sprite.frames.add_animation("idle")
	animated_sprite.frames.set_animation_speed("idle", 8)
	for i in range(8):
		animated_sprite.frames.add_frame("idle", load("res://Assets/cat/"+variety+"_idle_8fps/"+str(i)+".png"))
		
	animated_sprite.frames.add_animation("land")
	animated_sprite.frames.set_animation_loop("land", false)
	animated_sprite.frames.set_animation_speed("land", 8)
	for i in range(2):
		animated_sprite.frames.add_frame("land", load("res://Assets/cat/"+variety+"_land_8fps/"+str(i)+".png"))
		
	animated_sprite.frames.add_animation("run")
	animated_sprite.frames.set_animation_speed("run", 8)
	for i in range(10):
		animated_sprite.frames.add_frame("run", load("res://Assets/cat/"+variety+"_run_8fps/"+str(i)+".png"))
		
	animated_sprite.frames.add_animation("swipe")
	animated_sprite.frames.set_animation_speed("swipe", 8)
	for i in range(7):
		animated_sprite.frames.add_frame("swipe", load("res://Assets/cat/"+variety+"_swipe_8fps/"+str(i)+".png"))
		
	animated_sprite.frames.add_animation("walk")
	animated_sprite.frames.set_animation_speed("walk", 8)
	for i in range(8):
		animated_sprite.frames.add_frame("walk", load("res://Assets/cat/"+variety+"_walk_8fps/"+str(i)+".png"))
		
	animated_sprite.frames.add_animation("walk_fast")
	animated_sprite.frames.set_animation_speed("walk_fast", 8)
	for i in range(4):
		animated_sprite.frames.add_frame("walk_fast", load("res://Assets/cat/"+variety+"_walk_fast_8fps/"+str(i)+".png"))
		
	animated_sprite.frames.add_animation("climb")
	animated_sprite.frames.set_animation_speed("climb", 8)
	for i in range(8):
		animated_sprite.frames.add_frame("climb", load("res://Assets/cat/"+variety+"_wallclimb_8fps/"+str(i)+".png"))
		
	animated_sprite.frames.add_animation("grab")
	animated_sprite.frames.set_animation_speed("grab", 8)
	for i in range(8):
		animated_sprite.frames.add_frame("grab", load("res://Assets/cat/"+variety+"_wallgrab_8fps/"+str(i)+".png"))
		
	animated_sprite.frames.add_animation("release")
	animated_sprite.frames.set_animation_loop("release", false)
	animated_sprite.frames.add_frame("release", load("res://Assets/cat/"+variety+"_fall_from_grab_8fps/"+str(2)+".png"))
	
	animated_sprite.frames.add_animation("drag")
	animated_sprite.frames.set_animation_loop("drag", false)
	animated_sprite.frames.add_frame("drag", load("res://Assets/cat/"+variety+"_fall_from_grab_8fps/"+str(1)+".png"))

func game_over(position_x :int) -> void:
	OS.window_size = pet_size
	OS.window_position = Vector2(position_x,975)
	visible = true
	state = State.RELEASED

func game_start() -> void:
	self.state = State.STOP
#	修复窗口变化
	OS.window_position.y += OS.window_size.y - pet_size.y
	OS.window_size = pet_size
	animated_sprite.position = pet_size / 2
	self.visible = false


func _on_Area2D_mouse_entered() -> void:
	print("pet mouse entered")
