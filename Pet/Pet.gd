extends Control

onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var action_switch_timer: Timer = $ActionSwitchTimer
onready var action_on_wall_switch_timer: Timer = $ActionOnWallSwitchTimer
onready var expression_sprite :Sprite = $Expression
onready var expression_timer :Timer = $Expression/ExpressionTimer
onready var expression_animation_player: AnimationPlayer = $Expression/ExpressionAnimationPlayer

enum State { RELEASED, DRAGGING, ACTION, ACTION_ON_WALL }
enum Action { IDLE, WALK, RUN }
enum ActionOnWall { GRAB, CLIMB, JUMP }
enum Emotion { HAPPY, SAD, ANGRY }

#constant
const walk_speed := 100
const run_speed := 200
const climb_speed := 50
const jump_speed := 200
var screen_size := OS.get_screen_size()
const pet_size := Vector2(135, 95)
const pet_size_on_wall := Vector2(65, 115)
const window_size_popup := Vector2(135,120)
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
#	self.state = State.RELEASED
	expression_sprite.modulate.a = 0
	animated_sprite.position = pet_size

func _physics_process(delta: float) -> void:
	return
	print(animated_sprite.position)
	match self.state:
		State.DRAGGING:
			if get_global_mouse_position().x <= 1:
				if on_wall != Wall.LEFT:
					self.on_wall = Wall.LEFT
			elif get_global_mouse_position().x >= screen_size.x - 1:
				if on_wall != Wall.RIGHT:
					self.on_wall = Wall.RIGHT
			else:
				on_wall = Wall.NOT
				
			#to RELEASED
			if not Input.is_action_pressed("click"):
				self.state = State.RELEASED
			else:
				animated_sprite.position += get_global_mouse_position() - click_pos - pet_size / 2

		State.RELEASED:
			#to DRAGGING
			if Input.is_action_just_pressed("click"):
				self.state = State.DRAGGING
			#to ACTION_ON_WALL
			elif on_wall != Wall.NOT:
				self.state = State.ACTION_ON_WALL
			#to ACTION
			elif animated_sprite.position.y + pet_size.y >= screen_size.y:
				self.state = State.ACTION
			else:
				velocity.y += gravity * delta
				animated_sprite.position += velocity * delta
				
		State.ACTION:
			if animated_sprite.position.x <= 1:
				if on_wall != Wall.LEFT:
					self.on_wall = Wall.LEFT
			elif animated_sprite.position.x + pet_size.x >= screen_size.x - 1:
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
				pass
#				OS.window_position += velocity * delta
		State.ACTION_ON_WALL:
			if Input.is_action_just_pressed("click"):
				self.state = State.DRAGGING
			#when action_on_wall is jump, state will become RELEASED
			else:
				pass
#				OS.window_position += velocity * delta
	animated_sprite.position = screen_size / 2
	velocity = Vector2.ZERO


func set_state(new_state) -> void:
	match state:
		State.ACTION:
			action_switch_timer.stop()
		State.ACTION_ON_WALL:
			action_on_wall_switch_timer.stop()
#			get_viewport().size = window_size
#			get_parent().get_node("Pet").animated_sprite.position = Vector2(67, 47)

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
				animated_sprite.position.y = screen_size.y - pet_size.y
				velocity.y = 0
				animation_player.play("land") # will set action to idle
		State.ACTION_ON_WALL:
			expression_animation_player.stop()
			expression_sprite.modulate.a = 0
#			get_viewport().size = window_size_on_wall
#			get_parent().get_node("Pet").animated_sprite.position = Vector2(32, 58)
			match on_wall:
				Wall.LEFT:
					animated_sprite.flip_h = true
					animated_sprite.position.x = 0
				Wall.RIGHT:
					animated_sprite.flip_h = false
					animated_sprite.position.x = screen_size.x - pet_size_on_wall.x
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
			action_switch_timer.start(4 + self.emotion + 2 * randf()) # 4 ~ 6 to 6 ~ 8
			animation_player.play("idle")
		Action.WALK:
			self.mood += 1
			if randi() % 2 > 0:
				direction = -direction
				animated_sprite.flip_h = not animated_sprite.flip_h
			velocity = Vector2.RIGHT * walk_speed * direction
			action_switch_timer.start(4 - self.emotion + 2 * randf()) # 4 ~ 6 to 2 ~ 4
			animation_player.play("walk")
		Action.RUN:
			self.mood += 3
			if randi() % 4 > 0:
				direction = -direction
				animated_sprite.flip_h = not animated_sprite.flip_h
			velocity = Vector2.RIGHT * run_speed * direction
			action_switch_timer.start(2.01 - self.emotion) # 2 to 0
			animation_player.play("run")
			
	action = new_action


func set_action_on_wall(new_action_on_wall) -> void:
	match new_action_on_wall:
		ActionOnWall.GRAB:
			velocity = Vector2.ZERO
			action_on_wall_switch_timer.start(0.3 + randf() / 2)
			animation_player.play("grab")
		ActionOnWall.CLIMB:
			self.mood += 1
			velocity = Vector2.UP * climb_speed
			action_on_wall_switch_timer.start(1 + 2 * randf())
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
	mood = new_mood
	print(mood)
	
	if self.emotion != pre_emotion:
		match self.emotion:
			Emotion.HAPPY:
				expression_animation_player.play("happy")
			Emotion.SAD:
				expression_animation_player.play("sad")
			Emotion.ANGRY:
				expression_animation_player.play("angry")

#func pop_window(time, keyword) -> void:
#	var expression_frame :int
#	match keyword: 
#		"happy":
#			expression_frame = 13
#		"sad":
#			expression_frame = 14
#		"angry":
#			expression_frame = 15
#
#	get_viewport().size = window_size_popup
#	print(get_viewport_rect().size)
#	get_parent().get_node("Pet").animated_sprite.position = Vector2(67,72) 
#	expression_timer.start(time)
#	expression_sprite.frame = expression_frame
#	expression_sprite.visible = true


func get_emotion() -> int:
	if mood > 20:
		return Emotion.HAPPY
	elif mood > 0:
		return Emotion.SAD
	else:
		return Emotion.ANGRY


func _on_ActionSwitchTimer_timeout() -> void:
	match action:
		Action.IDLE:
			match randi() % 3:
				0, 1:
					self.action = Action.WALK
				2:
					self.action = Action.RUN
		Action.WALK:
			match randi() % 2:
				0:
					self.action = Action.RUN
				1:
					self.action = Action.IDLE
		Action.RUN:
			match randi() % 4:
				0:
					self.action = Action.WALK
				1, 2, 3:
					self.action = Action.IDLE


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
		var file_extension := file_path.get_extension()
		
		if file_extension in ["zip", "rar", "7z"]:
			OS.execute("powershell.exe", ["-Command", "./7-Zip/7z.exe", "x", file_path, "-o"+folder], false)


func _on_ExpressionAnimationPlayer_animation_started(anim_name: String) -> void:
#	get_parent().get_node("Pet").animated_sprite.position = Vector2(67,72) 
	pass
	
	
func _on_ExpressionAnimationPlayer_animation_finished(anim_name: String) -> void:
#		get_viewport().size = window_size
	#	OS.window_position.y +=  25
#		get_parent().get_node("Pet").animated_sprite.position = Vector2(67,47)
	pass
