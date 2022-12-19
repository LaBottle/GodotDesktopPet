extends Control


func _ready() -> void:
#	var output = []
#	OS.execute("powershell.exe", ["-Command", "dir"], true, output)
#	print(output.front().left(100))
#	OS.execute("powershell.exe", ["-Command", "cd", "..", ";", "dir"], true, output)
#	print(output.front().left(100))
#	OS.execute("powershell.exe", ["-Command", "dir"], true, output)
#	print(output.front().left(100))
	get_viewport().transparent_bg = true



func _on_Area2D_mouse_entered() -> void:
	get_node("memo").visible = true
	get_node("Timer").start(2)
	pass # Replace with function body.

#避免鬼畜所以改为了计时器
func _on_Timer_timeout() -> void:
	get_node("memo").visible = false
	pass # Replace with function body.
