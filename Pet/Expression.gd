extends Sprite

const size = Vector2(32, 38)

func new(emotion: String) -> Sprite:
	$ExpressionAnimationPlayer.play(emotion)
	return self

func _on_ExpressionAnimationPlayer_animation_finished(anim_name: String) -> void:
	get_parent().remove_child_window()
