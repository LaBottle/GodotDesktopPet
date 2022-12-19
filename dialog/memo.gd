extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

onready var dialogTimer := $Timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass





func _on_icon_pressed() -> void:
	get_node("PetPanel").visible = true
#	get_node("TextEdit").visible = true
	dialogTimer.start(3)
	pass # Replace with function body.


func _on_Timer_timeout() -> void:
	get_node("PetPanel").visible = false
#	get_node("TextEdit").visible = false
#	get_node("Panel/RichTextLabel").visible = false
	pass # Replace with function body.


#func _on_TextEdit_focus_entered() -> void:
#	get_parent().get_node("Timer").stop()
#	pass # Replace with function body.
#
#
#func _on_TextEdit_focus_exited() -> void:
#	get_parent().get_node("Timer").start()
#	pass # Replace with function body.
#
#func _on_TextEdit_cursor_changed() -> void:
#	get_parent().get_node("Timer").set_paused(true)
#	print("stop")
#	print(get_parent().get_node("Timer").is_paused())
#	pass # Replace with function body.
