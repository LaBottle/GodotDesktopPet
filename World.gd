extends Node2D

onready var pet_rect :ReferenceRect = $Pet/ReferenceRect
enum {RELEASED, CLICKED, DRAGGING}

var offset := Vector2.ZERO
var click_pos := Vector2.ZERO
func _ready() -> void:
	get_viewport().transparent_bg = true
	#OS.execute("powershell.exe", ["-Command", "./7-Zip/7z.exe", "x", "ost.7z"], false)
	
#	if Input.is_action_just_pressed("click"):
#		$Pet.statu = RELEASED
#		click_pos = get_local_mouse_position()
#	if Input.is_action_pressed("click"):
#		$Pet.statu = DRAGGING
#		OS.set_window_position(OS.window_position + get_global_mouse_position() - click_pos)
#	if event.is_action_pressed("click"):
#		if Rect2(pet_rect.rect_global_position, pet_rect.rect_size).has_point(get_global_mouse_position()):
#			statu = CLICKED
#	if statu == CLICKED and event.is_class("InputEventMouseMotion"):
#		statu = DRAGGING
#	if statu == DRAGGING:
#		if event.is_action_released("click"):
#			statu = RELEASED
#		else:
#			get_viewport().set
#			global_position = get_global_mouse_position() + offset
