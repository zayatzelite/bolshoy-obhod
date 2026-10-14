extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	scene.ui.hide()
	var camera:=Camera3D.new()
	scene.add_child(camera)
	camera.current=true
	camera.fov=55
	var shots=[[Vector3(-8,4,10),Vector3(-8,3.9,4.5)],[Vector3(0,4,7),Vector3(-6,3.8,3.5)],[Vector3(-8,3.7,1),Vector3(-8,4.2,4.5)]]
	for i in range(shots.size()):
		camera.position=shots[i][0]
		camera.look_at(shots[i][1])
		for tick in range(5):await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../cabin_joint_%d.png" % i)
	print("CABIN JOINT CAPTURE PASS: front, oblique and inside")
	quit()
