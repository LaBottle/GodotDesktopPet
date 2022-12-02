extends AnimatedSprite


onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var action_switch_timer: Timer = $ActionSwitchTimer
onready var action_on_wall_switch_timer: Timer = $ActionOnWallSwitchTimer
onready var expression_sprite :Sprite = $Expression
onready var expression_timer :Timer = $Expression/ExpressionTimer

enum State {RELEASED, DRAGGING, ACTION, ACTION_ON_WALL}
enum Action {IDLE, WALK, RUN}
enum ActionOnWall {GRAB, CLIMB, JUMP}

enum Mood {HAPPY, SAD, ANGRY}

#constant
const walk_speed := 100
const run_speed := 200
const climb_speed := 50
const jump_speed := 200
var screen_size := OS.get_screen_size()
const window_size := Vector2(135, 95)
const window_size_on_wall := Vector2(65, 115)
var gravity :float = ProjectSettings.get("physics/2d/default_gravity")

#variable
var state setget set_state
var action setget set_action
var action_on_wall setget set_action_on_wall
var velocity := Vector2.ZERO
var click_pos := Vector2.ZERO
var direction := 1

enum Wall {NOT=0, LEFT=-1, RIGHT=1}
var on_wall = Wall.NOT


func _ready() -> void:
	randomize()
	self.state = State.RELEASED
	self.mood = 40 #happy

func _physics_process(delta: float) -> void:
	print(velocity)
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
				OS.set_window_position(OS.window_position + get_global_mouse_position() - click_pos - window_size / 2)

		State.RELEASED:
			#to DRAGGING
			if Input.is_action_just_pressed("click"):
				self.state = State.DRAGGING
			#to ACTION_ON_WALL
			elif on_wall != Wall.NOT:
				self.state = State.ACTION_ON_WALL
			#to ACTION
			elif OS.window_position.y + window_size.y >= screen_size.y:
				self.state = State.ACTION
			else:
				velocity.y += gravity * delta
				OS.window_position += velocity * delta
				
		State.ACTION:
			if OS.window_position.x <= 1:
				if on_wall != Wall.LEFT:
					self.on_wall = Wall.LEFT
			elif OS.window_position.x + window_size.x >= screen_size.x - 1:
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
			get_viewport_rect().size = window_size
			get_parent().get_node("Pet").position = Vector2(67, 47)

	match new_state:
		State.RELEASED:
			if state != State.ACTION_ON_WALL:
				animation_player.play("release")
		State.DRAGGING:
			velocity = Vector2.ZERO
			click_pos = get_local_mouse_position()
			animation_player.play("drag")
		State.ACTION:
			if state == State.RELEASED:
				OS.window_position.y = screen_size.y - window_size.y
				velocity.y = 0
				animation_player.play("land") # will set action to idle
		State.ACTION_ON_WALL:
			get_viewport_rect().size = window_size_on_wall
			get_parent().get_node("Pet").position = Vector2(32, 58)
			match on_wall:
				Wall.LEFT:
					flip_h = true
					OS.window_position.x = 0
				Wall.RIGHT:
					flip_h = false
					OS.window_position.x = screen_size.x - window_size_on_wall.x
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
			action_switch_timer.start(1 + 2 * randf()) # 1 ~ 3
			animation_player.play("idle")
		Action.WALK:
			if randi() % 2 > 0:
				direction = -direction
				flip_h = not flip_h
			velocity = Vector2.RIGHT * walk_speed * direction
			action_switch_timer.start(4 + 2 * randf()) # 4 ~ 6
			animation_player.play("walk")
		Action.RUN:
			if randi() % 4 > 0:
				direction = -direction
				flip_h = not flip_h
			velocity = Vector2.RIGHT * run_speed * direction
			action_switch_timer.start(1.5 + randf()) # 1.5 ~ 2.5
			animation_player.play("run")
			
	action = new_action


func set_action_on_wall(new_action_on_wall) -> void:
	match new_action_on_wall:
		ActionOnWall.GRAB:
			velocity = Vector2.ZERO
			action_on_wall_switch_timer.start(0.3 + randf() / 2)
			animation_player.play("grab")
		ActionOnWall.CLIMB:
			velocity = Vector2.UP * climb_speed
			action_on_wall_switch_timer.start(1 + 2 * randf())
			animation_player.play("climb")
		ActionOnWall.JUMP:
			match on_wall:
				Wall.LEFT:
					flip_h = false
					direction = 1
				Wall.RIGHT:
					flip_h = true
					direction = -1
			velocity = Vector2.LEFT * jump_speed * on_wall
			animation_player.play("jump_from_grab")
			on_wall = Wall.NOT
			self.state = State.RELEASED

	action_on_wall = new_action_on_wall


func get_mood() -> int:
	return mood
	
func change_mood(newmood) -> void:
	mood = newmood
	if mood == 20:
		pop_window(3,"happy")
	elif mood == 0:
		pop_window(3,"sad")
#	else:
#		pop_window(3,"angry")

func pop_window(time,keyword) -> void:
	var expression_frame :int
	match keyword: 
		"happy":
			expression_frame = 13
		"sad":
			expression_frame = 14
		"angry":
			expression_frame = 15
			
	get_viewport().size = Vector2(135,120)
	OS.window_position.y -=  25
	get_parent().get_node("Pet").position.y += 25 
	expression_timer.start(time)
	expression_sprite.frame = expression_frame
	expression_sprite.visible = true



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
