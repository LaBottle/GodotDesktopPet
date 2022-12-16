extends RigidBody2D


func _ready() -> void:
	randomize()
	self.bounce=1
	get_node(".").set_axis_velocity(Vector2(randi()%10*10-50,0))
#	get_node(".").apply_impulse(Vector2.ZERO,)
	

