extends Node2D


var size = Vector2(110, 208)
onready var option_button: OptionButton = $OptionButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	option_button.add_item("黑色")
	option_button.add_item("棕色")
	option_button.add_item("白色")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_OptionButton_item_selected(index: int) -> void:
	get_parent().set_variety(index)
	get_parent().remove_child_window()
