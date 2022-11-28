extends KinematicBody2D

onready var AnimatedSprite = $AnimatedSprite
onready var Timer = $StateSwitchTimer

enum {RELEASED, DRAGGING, LANDING, IDLE}

var random = RandomNumberGenerator.new()
var state := RELEASED
var velocity := Vector2.ZERO
var gravity :float = ProjectSettings.get("physics/2d/default_gravity")
var click_pos := Vector2.ZERO
var screen_size := OS.get_screen_size()
var offset := Vector2(60, 35)
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	random.randomize()
	state = DRAGGING
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	print(OS.window_position)
	match state:
		DRAGGING:
			#进行拖拽
			if Input.is_action_pressed("click"):
				OS.set_window_position(OS.window_position + get_global_mouse_position() - click_pos - offset)
				
			#取消拖拽
			else:
				state = RELEASED
				AnimatedSprite.play("release")
				
		RELEASED:
			#被拖拽
			if Input.is_action_just_pressed("click"):
				velocity = Vector2.ZERO
				click_pos = get_local_mouse_position()
				state = DRAGGING
				AnimatedSprite.play("drag")
				continue
				
			#落地
			if OS.window_position.y + 75 >= screen_size.y:
				OS.window_position.y = screen_size.y - 75
				velocity.y = 0
				#开启计时器，让land动作完整
				Timer.wait_time = 3.0
				Timer.start(1)
				state = LANDING
				AnimatedSprite.play("land")
				
			#状态不改变
			else:
				velocity.y += gravity * delta
				OS.window_position = OS.window_position.move_toward(OS.window_position + velocity*delta, INF)
				
		LANDING:
			#被拖拽
			if Input.is_action_just_pressed("click"):
				state = DRAGGING
				AnimatedSprite.play("drag")
				continue
				
			#land动画结束
			if Timer.is_stopped():
				#重启计时器
				Timer.wait_time = 5.0
				Timer.start(1)
				state = IDLE
				AnimatedSprite.play("idle")
				
		IDLE:
			#被拖拽
			if Input.is_action_just_pressed("click"):
				state = DRAGGING
				AnimatedSprite.play("drag")
				continue
			
			#状态不变	
			if Timer.time_left == 0:
				print("finsh")
				match random.randi()%10:
					1:
						Timer.wait_time = 3.0
						AnimatedSprite.play("walk")
					2:
						Timer.wait_time = 1.0
						AnimatedSprite.play("run")
					_:
						Timer.wait_time = 10.0
						AnimatedSprite.play("idle")
				Timer.start(1)
			pass
			
