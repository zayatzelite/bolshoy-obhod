extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.message_timer = 0
	scene.player.position = preload("res://scripts/exploration_path.gd").point(35)+Vector3(0,.3,0)
	scene.player.camera.look_at(preload("res://scripts/exploration_path.gd").point(43)+Vector3(0,.5,0))
	for tick in range(6):await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../exploration_path_preview.png")
	print("EXPLORATION CAPTURE PASS")
	quit()
