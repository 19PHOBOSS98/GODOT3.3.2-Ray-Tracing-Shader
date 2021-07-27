tool
extends MeshInstance


func update_view(gt):
	#if(Engine.editor_hint):
		self.get_active_material(0).set_shader_param("camera_basis", gt.basis)
		self.get_active_material(0).set_shader_param("camera_global_position", gt.origin)

func update_sphere(so,id):
	match id:
		0:
			self.get_active_material(0).set_shader_param("sphere_o", so)
		1:
			self.get_active_material(0).set_shader_param("sphere_o1", so)
		2:
			self.get_active_material(0).set_shader_param("sphere_o2", so)
		3:
			self.get_active_material(0).set_shader_param("sphere_o3", so)
		4:
			self.get_active_material(0).set_shader_param("sphere_o4", so)
		7:
			self.get_active_material(0).set_shader_param("sphere_o8", so)
		8:
			self.get_active_material(0).set_shader_param("sphere_o9", so)
		9:
			self.get_active_material(0).set_shader_param("sphere_o10", so)
"""
		5:
			self.get_active_material(0).set_shader_param("sphere_o5", so)
		6:
			self.get_active_material(0).set_shader_param("sphere_o7", so)
		10:
			self.get_active_material(0).set_shader_param("sphere_o11", so)
"""
		
func turn_on_shadows(shadows_on):
	self.get_active_material(0).set_shader_param("shadow", shadows_on)

func update_d_light(gt_fwd,energy):
	self.get_active_material(0).set_shader_param("d_light_dir", gt_fwd)
	self.get_active_material(0).set_shader_param("d_light_energy", energy)

func change_mat(mat):
	self.get_active_material(0).set_shader_param("mat", mat)






