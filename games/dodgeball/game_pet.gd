extends KinematicBody2D

enum PetVariety {black, brown, white}
export(PetVariety) var pet_variety = PetVariety.white
onready var animated_sprite = $AnimatedSprite
var child_window: Node2D = null setget add_child_window

var velocity = Vector2.ZERO
var run_speed := 300
var is_jumping = false
var gravity :float = ProjectSettings.get("physics/2d/default_gravity")
var jump_force = 500

func _ready() -> void:
	set_variety(pet_variety)
	pass

func _physics_process(delta):
	velocity =  move_and_slide(velocity,Vector2.UP)
	if is_on_floor():
		is_jumping = false

func _input(event):
	if event.is_action_pressed("ui_up") and not is_jumping:
		velocity.y = -jump_force
		is_jumping = true

func _process(delta: float) -> void:
	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = direction * run_speed
	velocity.y += gravity * delta
	
	if is_jumping:
		animated_sprite.play("run")
		if direction != 0:
			animated_sprite.flip_h = direction < 0
	elif direction == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("walk")
		animated_sprite.flip_h = direction < 0


func set_variety(new_variety) -> void:
	pet_variety = new_variety
	var variety :String = PetVariety.keys()[pet_variety]
	animated_sprite.frames.clear_all()
	
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
			
	animated_sprite.frames.add_animation("walk")
	animated_sprite.frames.set_animation_speed("walk", 8)
	for i in range(8):
		animated_sprite.frames.add_frame("walk", load("res://Assets/cat/"+variety+"_walk_8fps/"+str(i)+".png"))
		
	animated_sprite.frames.add_animation("walk_fast")
	animated_sprite.frames.set_animation_speed("walk_fast", 8)
	for i in range(4):
		animated_sprite.frames.add_frame("walk_fast", load("res://Assets/cat/"+variety+"_walk_fast_8fps/"+str(i)+".png"))
		
func add_child_window(node: Node2D) -> void:
	add_child(node)
	child_window = node

func remove_child_window() -> void:
	if child_window != null:
		child_window.queue_free()
		remove_child(child_window)
		child_window = null

