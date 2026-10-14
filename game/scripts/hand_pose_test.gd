extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	scene.set_physics_process(false)
	scene.message_timer = 0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for index in range(3):
		var item: Node3D = scene.rubbish[0]
		scene.pickup(item)
		var pose := item.transform
		scene.stow_or_retrieve()
		scene.player.rotation.y += .6
		scene.stow_or_retrieve()
		assert(item.transform.is_equal_approx(pose),"Retrieved item pose differs from pickup")
		for tick in range(6):await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../patrol_hand_prop_%d.png" % index)
		scene.stow_or_retrieve()
	print("HAND POSE PASS: bottle, can and cup preserve local pose across backpack retrieval after player turns")
	quit()
