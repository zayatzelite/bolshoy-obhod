extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	scene.message_timer=0
	var camera:=Camera3D.new()
	scene.add_child(camera)
	camera.current=true
	camera.fov=72
	var shots=[ [Vector3(49,2,-28),Vector3(136,14,-75)], [Vector3(50,2,-160),Vector3(136,14,-105)], [Vector3(110,65,-100),Vector3(150,8,-95)] ]
	for i in range(shots.size()):
		camera.position=shots[i][0]
		camera.look_at(shots[i][1])
		for tick in range(5):await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../landscape_angle_%d.png" % i)
	print("LANDSCAPE ANGLES CAPTURE PASS: north, south, elevated rock slope")
	quit()
