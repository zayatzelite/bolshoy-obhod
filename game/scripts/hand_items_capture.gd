extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	scene.player.position = Vector3(0,.2,-10)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for index in range(3):
		if scene.held_item:scene.stow_or_retrieve()
		scene.pickup(scene.rubbish[0])
		for tick in range(5):await process_frame
		await RenderingServer.frame_post_draw
		assert(scene.player.carrying_hand.visible)
		root.get_texture().get_image().save_png("res://../hand_item_%d.png" % index)
	print("HAND ITEMS CAPTURE PASS: bottle, can, cup with Blender hand")
	quit()
