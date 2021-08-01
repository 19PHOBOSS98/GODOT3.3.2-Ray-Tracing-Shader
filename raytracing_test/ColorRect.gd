extends ColorRect



func _on_PCamera_camera_moving(mvn):
	if(mvn):
		pass
		#print("moving")
		#visible = false
	else:
		pass
		#print("not moving")
		#visible = true



func _on_ColorRect_visibility_changed():
	if(visible):
		#print("vis")
		print("not moving")
		#self.get_material().set_shader_param("active", true)
	else:
		print("moving")
		#self.get_material().set_shader_param("active", false)


