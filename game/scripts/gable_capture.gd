extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.set_physics_process(false)
	scene.player.position = scene.bases[0]+Vector3(0,.2,0)
	scene.player.camera.look_at(scene.bases[0]+Vector3(0,4,3.5))
	scene.hud.hide()
	for tick in range(5):await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../cabin_gable_preview.png")
	print("GABLE CAPTURE PASS: interior front roof joint")
	quit()
