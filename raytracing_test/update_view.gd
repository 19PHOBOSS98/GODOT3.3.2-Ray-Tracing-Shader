tool
extends MeshInstance
#onready var rng = RandomNumberGenerator.new()
#func _ready():
	#rng.randomize()

#func _process(_delta):

	#self.get_active_material(0).set_shader_param("PixelOffset", Vector2(rng.randf_range(0.0,1.0),rng.randf_range(0.0,1.0)))
	
func update_view(gt):
	#if(Engine.editor_hint):
		self.get_active_material(0).set_shader_param("camera_basis", gt.basis)
		#self.get_active_material(0).set_shader_param("camera_basis", Basis(gt.basis.x,gt.basis.y,gt.basis.z))
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
	#print("mat: ",mat)
	self.get_active_material(0).set_shader_param("mat", mat)

func update_boundedPlane(gt,size):
	self.get_active_material(0).set_shader_param("p1T_inv", gt.basis)
	self.get_active_material(0).set_shader_param("p1n", gt.basis.y)
	self.get_active_material(0).set_shader_param("p1o",gt.origin)
	self.get_active_material(0).set_shader_param("plane_dimension",size/2)
	self.get_active_material(0).set_shader_param("p1ox",gt.basis.xform_inv(gt.origin))# xform_inv # transforms using the inverted matrix: the one we get when we print out Basis
	#gt.basis.xform(gt.origin) #transforms using the non inverted matrix: the one that we see when we call basis.z
	
var BT
var AT
func determine_Portal_Priority(lead_portal,portal,portal_id):
	var id = clamp(portal_id,1,4)# 4 pairs
	if(lead_portal):
		#AT = portal.global_transform

		update_PortalPlaneA(id,portal.global_transform,portal.get_mesh().size)
	else:
		#BT = portal.global_transform
		update_PortalPlaneB(id,portal.global_transform)
		#calc()

func calc():
	var Va = AT.inverse()*Vector3(0,1,0)
	prints("AT_inv*global_vec3(0,1,0): ",Va)
	var Vob = BT*Va
	prints("BT*Va: ",Vob)
		
func update_PortalPlaneA(id,gtA,sizeA):
	
	"""
	self.get_active_material(0).set_shader_param("portal1An", gtA.basis.y)
	self.get_active_material(0).set_shader_param("portal1Ao",gtA.origin)
	self.get_active_material(0).set_shader_param("portal1A_dimension",sizeA/2)
	self.get_active_material(0).set_shader_param("portal1AT4_inv", gtA.inverse())
	self.get_active_material(0).set_shader_param("portal1AT3_inv", gtA.basis.inverse())
	self.get_active_material(0).set_shader_param("portal1Aox",gtA.basis.xform_inv(gtA.origin))# xform_inv # transforms using the inverted matrix: the one we get when we print out Basis
	#gt.basis.xform(gt.origin) #transforms using the non inverted matrix: the one that we see when we call basis.z
	"""

	
	self.get_active_material(0).set_shader_param("portal"+str(id)+"An", gtA.basis.y)
	self.get_active_material(0).set_shader_param("portal"+str(id)+"Ao",gtA.origin)
	self.get_active_material(0).set_shader_param("portal"+str(id)+"A_dimension",sizeA/2)
	self.get_active_material(0).set_shader_param("portal"+str(id)+"AT4_inv", gtA.inverse())
	self.get_active_material(0).set_shader_param("portal"+str(id)+"AT3_inv", gtA.basis.inverse())



func update_PortalPlaneB(id,gtB):
	self.get_active_material(0).set_shader_param("portal"+str(id)+"Bn", gtB.basis.y)
	self.get_active_material(0).set_shader_param("portal"+str(id)+"BT4", gtB)
	self.get_active_material(0).set_shader_param("portal"+str(id)+"BT3", gtB.basis)#.rotated(Vector3(0,1,0),(180*PI/180))) #skews image for some reason
	
	
	
	
	
	
	
	
	
	
	
