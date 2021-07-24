tool
extends Camera

func _ready():
	pass
	#prints(self.global_transform.basis.x.z,self.global_transform.basis.y.z,self.global_transform.basis.z.z)

func _process(_delta):
	
	#get_tree().call_group("SCREENS","update_view",global_transform)
	
	#if(Engine.editor_hint):
		var b = self.global_transform.basis
		$screen.get_active_material(0).set_shader_param("camera_basis", b)
		$screen.get_active_material(0).set_shader_param("camera_global_position", self.global_transform.origin)
	
		####$screen.get("material/0").set("shader_param/camera_direction", Vector3 (self.global_transform.basis.x.z,self.global_transform.basis.y.z,self.global_transform.basis.z.z))
		##$screen.get("material/0").set("shader_param/camera_direction", self.global_transform.basis.z)
		####$screen.get("material/0").set("shader_param/camera_up", Vector3 (self.global_transform.basis.y.x,self.global_transform.basis.y.y,self.global_transform.basis.y.z))
		##$screen.get("material/0").set("shader_param/camera_up", self.global_transform.basis.y)
		#$screen.get("material/0").set("shader_param/camera_up", Vector3 (self.global_transform.basis.y.x,self.global_transform.basis.y.y,self.global_transform.basis.y.z))
		
		#$screen.get("material/0").set("shader_param/camera_direction", self.global_transform.basis.z)
		#$screen.get("material/0").set("shader_param/camera_direction", Vector3 (self.global_transform.basis.x.z,self.global_transform.basis.y.z,self.global_transform.basis.z.z))
		###$screen.get("material/0").set("shader_param/camera_transform", self.global_transform.basis)
		
