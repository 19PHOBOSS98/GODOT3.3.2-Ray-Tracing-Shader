#tool
extends Camera
class_name PlayerCams

var debug = true
signal camera_moved(cam)
func _ready():
	add_to_group("PlayerCams")
	get_tree().call_group("mirrors","_on_Notifier_camera_entered",self)
	get_tree().call_group("mirrros","_on_Notifier_camera_exited",self)


#func _process(delta):
	#$V2.text = "GT: "+String(self.global_transform.basis)
	#if(Engine.editor_hint):
		#var b = self.global_transform.basis
		##$screen2.get_active_material(0).set_shader_param("camera_basis", b)
		##$screen2.get_active_material(0).set_shader_param("camera_global_position", self.global_transform.origin)
		#########get_tree().call_group("SCREENS","update_view",self.global_transform)
#	get_tree().call_group("mirrors","update_cam",global_transform)


					
func start_update():
	if(debug):
		#get_tree().call_group("portals","update_cam",self,0)
		emit_signal("camera_moved", global_transform)
