extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#prints("global_transform.basis: \n",global_transform.basis)#this gives you the inverse of the axis
	#prints("indiv: \n",global_transform.basis.x,global_transform.basis.y,global_transform.basis.z)#you need to call them individually to get the original transform matrix
	#print(get_mesh().size)
	get_tree().call_group("SCREENS","update_boundedPlane",self.global_transform,get_mesh().size)
