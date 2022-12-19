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


func _on_World_mouse_entered() -> void:
	print("world_enter")
	pass # Replace with function body.
