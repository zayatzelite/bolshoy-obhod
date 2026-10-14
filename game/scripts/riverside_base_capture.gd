extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.position = Vector3(18,3,-132)
	scene.player.camera.look_at(Vector3(30,1,-154))
	for tick in range(5):await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../riverside_base_preview.png")
	print("RIVERSIDE BASE CAPTURE PASS")
	quit()
