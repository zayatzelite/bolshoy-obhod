extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var item: Node3D = scene.rubbish[0]
	scene.player.position = item.position+Vector3(0,0,1.4)
	scene.player.camera.look_at(item.global_position,Vector3.UP)
	scene.update_focus()
	assert(scene.focused_item==item,"Raycast failed to select litter")
	scene.prompt.text = "E — взять бутылку в руки"
	for i in range(8):await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../patrol_item_outline.png")
	scene.pickup(item)
	scene.player.camera.rotation = Vector3.ZERO
	scene.player.set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for i in range(8):await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../patrol_item_held.png")
	print("ITEM VISUAL PASS: camera ray selected bottle, outline and held captures saved")
	quit()
