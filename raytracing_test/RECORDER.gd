extends Node

var frames = []

func _ready():
	var ret = VisualServer.connect("frame_post_draw",self,"save_frames_to_buffer")

var stop = false
func _input(event):
	if event.is_action_pressed("c"):
		stop = !stop
		save_frame()

func save_frames_to_buffer():
	if(!stop):
		frames.append(get_viewport().get_texture().get_data())
	#.save_png("res://frames/cap.png")

func save_frame():
	var img = 0
	for frame in frames:
		frame.save_png("/Users/PH0B0SS/Desktop/frames/cap_"+str(img)+".png")
		img+=1
	
	print("pngs saved !")
