extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.message_timer = 0
	scene.player.position = Vector3(46,.3,-80)
	scene.player.camera.look_at(Vector3(68,-.3,-95))
	for tick in range(5):await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../riverbank_preview.png")
	print("RIVERBANK CAPTURE PASS")
	quit()
