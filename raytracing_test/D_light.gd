
extends Position3D

var shadows_on = false
var energy = 1.0
var mat = 1
func _process(_delta):
	if Input.is_action_pressed("inc_intensity"):
		energy =clamp(energy+0.1,0.0,16.0)
	if Input.is_action_pressed("dec_intensity"):
		energy =clamp(energy-0.1,0.0,16.0)
	if Input.is_action_pressed("pitch_up"):
		rotation_degrees.x += 1
	if Input.is_action_pressed("pitch_down"):
		rotation_degrees.x -= 1
	if Input.is_action_pressed("yaw_left"):
		rotation_degrees.y += 1
	if Input.is_action_pressed("yaw_right"):
		rotation_degrees.y -= 1
	if Input.is_action_just_pressed("toggle_shadows"):
		get_tree().call_group("SCREENS","turn_on_shadows",shadows_on)
		shadows_on = !shadows_on
	if Input.is_action_just_pressed("change_mat"):
		#print("mat: "+str(mat))
		get_tree().call_group("SCREENS","change_mat",mat)
		#mat = mat+1 if(mat<4) else 0
		mat += 1
		mat %= 4
		

	get_tree().call_group("SCREENS","update_d_light",self.global_transform.basis.z,energy)

