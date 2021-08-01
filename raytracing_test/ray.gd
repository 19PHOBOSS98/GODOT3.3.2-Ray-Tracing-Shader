extends Spatial

var tog = false
func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta):
	$FPS.text = "FPS: "+str(Performance.get_monitor(Performance.TIME_FPS))
	if Input.is_action_just_pressed("ui_cancel"):
		if(tog):
			#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		tog = !tog


func _on_PCamera_camera_moved(cam):
	pass # Replace with function body.
