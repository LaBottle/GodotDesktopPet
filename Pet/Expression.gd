extends Sprite

const size = Vector2(32, 38)
var event
func _ready() -> void:
	modulate.a = 0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click") and event == "ballgame":
		get_parent().game_start()
		#实例化游戏场景
		var s = preload("res://games/dodgeball/game.tscn").instance()
		s.get_node("pet").position.x = OS.window_position.x - OS.get_screen_size().x/2 + 585
		get_parent().get_parent().add_child(s)
#		get_tree().change_scene("res://games/dodgeball/game.tscn")
		self._on_ExpressionAnimationPlayer_animation_finished(event)

func new(emotion: String) -> Sprite:
	event = emotion
	$ExpressionAnimationPlayer.play(event)
	return self

func _on_ExpressionAnimationPlayer_animation_finished(anim_name: String) -> void:
	get_parent().remove_child_window()

