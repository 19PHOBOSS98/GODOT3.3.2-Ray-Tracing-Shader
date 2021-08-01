extends MeshInstance

func _ready():
	var gtbasis = global_transform.basis
	print("gtbasis:",gtbasis)
	#prints("gtbasis rotated:",gtbasis.rotated(gtbasis.z,(180*PI/180)))
	get_tree().call_group("SCREENS","determine_Portal_Priority",false,self,2)

	pass
