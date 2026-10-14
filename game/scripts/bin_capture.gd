extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.message_timer = 0
	scene.player.position = Vector3(-9.4,.2,-38.6)
	scene.player.camera.look_at(Vector3(-9.4,.5,-40))
	for tick in range(5):await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../bin_detail_preview.png")
	print("BIN CAPTURE PASS")
	quit()
