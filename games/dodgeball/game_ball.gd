extends RigidBody2D

export var contact_left:= 30

func _ready() -> void:
	self.position.x = rand_range(0,OS.get_real_window_size().x)
	self.bounce=1
	

func _process(delta: float) -> void:
#	
	pass
	
func setType(falltype: int)->void:
	match falltype:
		1:
#			key
			get_node("Sprite").frame = 27
		2:
#			heart
			get_node("Sprite").frame = 44
		3:
#			diamond
			get_node("Sprite").frame = 67
		4:
#			thorn
			get_node("Sprite").frame = 68	
	pass

func _on_ball_body_entered(body: Node) -> void:
	self.contact_left = self.contact_left - 1
	if body is KinematicBody2D:
		if(get_node("Sprite").frame == 68):
			show_expression("sad")
		else:
			dead()
		
	elif self.contact_left <0:
		dead()
	pass # Replace with function body.

func dead()-> void:
	queue_free()
	pass
	
func show_expression(emotion:String)->void:
	get_parent().get_node("pet").child_window = preload("res://Pet/Expression.tscn").instance().new(emotion)


