extends AnimatedSprite

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var action_switch_timer: Timer = $ActionSwitchTimer

enum State {RELEASED, DRAGGING, ACTION}
enum Action {IDLE, WALK, RUN}


#constant
const walk_speed := 200
const run_speed := 400
const speed_in_wall := 150
var screen_size := OS.get_screen_size()
const window_offset := Vector2(60, 35)
var gravity :float = ProjectSettings.get("physics/2d/default_gravity")

#variable
var state setget set_state, get_state
var action setget set_action, get_action
var velocity := Vector2.ZERO
var click_pos := Vector2.ZERO
var direction = 1

func _ready() -> void:
	randomize()
	self.state = State.RELEASED


func _physics_process(delta: float) -> void:
	print(action_switch_timer.time_left)
	match self.state:
		State.DRAGGING:
			#TO RELEASED
			if not Input.is_action_pressed("click"):
				self.state = State.RELEASED
			else:
				OS.set_window_position(OS.window_position + get_global_mouse_position() - click_pos - window_offset)

				
		State.RELEASED:
			#TO DEAGGING
			if Input.is_action_just_pressed("click"):
				self.state = State.DRAGGING
			#TO ACTION
			elif OS.window_position.y + 75 >= screen_size.y:
				self.state = State.ACTION
			else:
				velocity.y += gravity * delta
				OS.window_position = OS.window_position.move_toward(OS.window_position + velocity*delta, INF)
				
#		LANDING:
#			#被拖拽
#			if Input.is_action_just_pressed("click"):
#				self.state = DRAGGING
#				animated_sprite.play("drag")
#
#
#			#land动画结束
#			if state_switch_timer.is_stopped():
#				#重启计时器
#				state_switch_timer.wait_time = 5.0
#				state_switch_timer.start(1)
#				self.state = IDLE
#				animated_sprite.play("idle")
				
		State.ACTION:
			#被拖拽
			if Input.is_action_just_pressed("click"):
				self.state = State.DRAGGING
				return
			else:
				OS.window_position = OS.window_position.move_toward(OS.window_position + velocity * delta, INF)



func set_state(new_state) -> void:
	state = new_state
	match new_state:
		State.RELEASED:
			animation_player.play("release")
		State.DRAGGING:
			action_switch_timer.stop()
			velocity = Vector2.ZERO
			click_pos = get_local_mouse_position()
			animation_player.play("drag")
		State.ACTION:
			OS.window_position.y = screen_size.y - 75
			velocity.y = 0
			animation_player.play("land") # will set action to idle

			
func get_state() -> int:
	return state
	
func set_action(new_action) -> void:
	action = new_action

	match new_action:
		Action.IDLE:
			velocity = Vector2.ZERO
			action_switch_timer.start(2 + 2 * randf()) # 2 ~ 4
			animation_player.play("idle")
		Action.WALK:
			if randi() % 2 == 1:
				direction = 1
				flip_h = false
			else:
				direction = -1
				flip_h = true
			velocity = Vector2(walk_speed * direction, 0)
			action_switch_timer.start(4 + 2 * randf()) # 4 ~ 6
			animation_player.play("walk")
		Action.RUN:
			if randi() % 4 == 1:
				direction = 1
				flip_h = false
			else:
				direction = -1
				flip_h = true
			velocity = Vector2(run_speed * direction, 0)
			action_switch_timer.start(1.5 + randf()) # 1.5 ~ 2.5
			animation_player.play("walk")

func get_action() -> int:
	return action

func _on_ActionSwitchTimer_timeout() -> void:
	var next_action = randi() % (Action.size() - 1)
	if next_action >= action:
		next_action += 1
	self.action = next_action
