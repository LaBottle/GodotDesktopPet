extends Control

func _ready() -> void:
#	get_viewport().transparent_bg = true
	OS.window_position = Vector2.ZERO
	get_viewport_rect().size = OS.get_screen_size()
	rect_size = OS.get_screen_size()
