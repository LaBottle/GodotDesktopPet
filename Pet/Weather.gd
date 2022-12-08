extends Node2D

const size = Vector2(100, 65)
const weather_api_key = "d0q95km0prqt038u"
onready var ip_api_request: HTTPRequest = $IPAPIRequest
onready var weather_api_request: HTTPRequest = $WeatherAPIRequest

func _ready() -> void:
	$Sprite.modulate.a = 0
	$Label.modulate.a = 0
	ip_api_request.request("https://ip.seeip.org/jsonip?")

func _on_IPAPIRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("The IP API HTTP request failed")
		get_parent().remove_child_window()
		return
	var json: Dictionary = parse_json(body.get_string_from_utf8())
	weather_api_request.request("http://api.yytianqi.com/weatherhours?city=%s&key=%s" % [json.ip, weather_api_key])


func _on_WeatherAPIRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("The weather API HTTP request failed")
		get_parent().remove_child_window()
		return
	var json: Dictionary = parse_json(body.get_string_from_utf8())
	var data: Dictionary = json.data.list[0]
	var is_night :int = OS.get_time().hour < 6 or OS.get_time().hour >= 18
	$Sprite.texture = load("res://Assets/weather_icon/%s_%s.png" % [data.numtq, is_night])
	$Label.text = "%s°C" % data.qw
	$AnimationPlayer.play("play")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	get_parent().remove_child_window()
