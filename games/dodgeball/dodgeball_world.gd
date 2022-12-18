extends Node2D

export (PackedScene) var Ball = preload("res://games/dodgeball/ball.tscn")
onready var timer = $Timer

func _ready() -> void:
	get_viewport().transparent_bg = true
	OS.window_size = Vector2(1024, 600)
	OS.window_position = Vector2((OS.get_screen_size().x - 1024) / 2, OS.get_screen_size().y - 600)
	print("game_start")
	timer.start(1)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_parent().get_node("Pet").game_scene_over(get_node("pet").position.x+OS.get_screen_size().x/2-585)
		get_parent().remove_child(self)

	pass
	
func _on_Timer_timeout() -> void:
	var ball = Ball.instance()
	ball.set_type(randi() % 4)
	add_child(ball)




