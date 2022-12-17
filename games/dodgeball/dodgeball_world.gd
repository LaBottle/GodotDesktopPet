extends Node2D

export (PackedScene) var ball
onready var timer = $Timer


func _ready() -> void:
	get_viewport().transparent_bg = true
	
	OS.window_size = Vector2(1024, 600)
	OS.window_position = Vector2((OS.get_screen_size().x-1024)/2,OS.get_screen_size().y-600)
	timer.start(2)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
#		get_tree().change_scene_to(global_data.previous_scene)
		get_tree().change_scene("res://World.tscn")

func _on_Timer_timeout() -> void:
	var a = ball.instance()
	a.setType(randi()%4)
	add_child(a)

func set_pet_position(locate:Vector2) ->void:
	get_node("ball").position.x = position.x
	pass


