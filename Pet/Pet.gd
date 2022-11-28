extends KinematicBody2D


enum {RELEASED, DRAGGING, WALKING, IDLE}


var state := RELEASED
var velocity := Vector2.ZERO
var gravity :float = ProjectSettings.get("physics/2d/default_gravity")
var click_pos := Vector2.ZERO
var screen_size := OS.get_screen_size()
var offset := Vector2(60, 35)
# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	print(OS.window_position)
	match state:
		DRAGGING:
			if Input.is_action_pressed("click"):
				OS.set_window_position(OS.window_position + get_global_mouse_position() - click_pos - offset)
			else:
				state = RELEASED
		RELEASED:
			if Input.is_action_just_pressed("click"):
				velocity = Vector2.ZERO
				state = DRAGGING
				click_pos = get_local_mouse_position()
				continue
			velocity.y += gravity * delta
			if OS.window_position.y + 75 >= screen_size.y:
				velocity.y = 0
				OS.window_position.y = screen_size.y - 75
			else:
				OS.window_position = OS.window_position.move_toward(OS.window_position + velocity*delta, INF)
