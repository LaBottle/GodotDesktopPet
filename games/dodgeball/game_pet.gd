extends KinematicBody2D


enum PetVariety {black, brown, white}
export(PetVariety) var pet_variety = PetVariety.white
onready var animated_sprite = $AnimatedSprite


var velocity = Vector2.ZERO
var gravity :float = ProjectSettings.get("physics/2d/default_gravity")
var run_speed := 300
func _ready() -> void:
	
	set_variety(pet_variety)
	pass # Replace with function body.

func _physics_process(delta):
	velocity =  move_and_slide(velocity,Vector2.UP)

func _process(delta: float) -> void:
	var direction = Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	velocity.x = direction * run_speed
	velocity.y += gravity * delta
	
#	if is_jumping:
#		animation_player.play("jump")
	if direction == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")
		animated_sprite.flip_h = direction < 0


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
