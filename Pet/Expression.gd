extends Sprite

const size = Vector2(32, 38)
var event

func _ready() -> void:
	modulate.a = 0

func _process(delta: float) -> void:
#															待修改
	if Input.is_action_just_pressed("click") and event == "happy":
#		global_data.previous_scene = get_tree().get_current_scene().duplicate()
		get_tree().change_scene("res://games/dodgeball/game.tscn")
		pass

func new(emotion: String) -> Sprite:
	event = emotion
	$ExpressionAnimationPlayer.play(emotion)
	print(emotion)
	return self

func _on_ExpressionAnimationPlayer_animation_finished(anim_name: String) -> void:
	get_parent().remove_child_window()
