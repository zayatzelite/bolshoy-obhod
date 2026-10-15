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
	camera.fov=60
	var base:Vector3=scene.bases[0]
	var shots=[[Vector3(0,1.1,4.5),Vector3(0,.10,3.70)],[Vector3(2.8,1.48,7.8),Vector3(2.8,1.48,6.2)]]
	for i in range(shots.size()):
		camera.position=base+shots[i][0]
		camera.look_at(base+shots[i][1])
		for tick in range(5):await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("C:/Users/zayatz/Downloads/lenskiy stolbi/base_detail_%d.png" % i)
	print("BASE DETAIL CAPTURE PASS")
	quit()
