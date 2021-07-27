extends RigidBody



func _process(_delta):
	if(linear_velocity.length() > 0):
		get_tree().call_group("SCREENS","update_sphere",self.global_transform.origin,0)

