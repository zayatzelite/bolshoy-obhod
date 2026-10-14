extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.set_physics_process(false)
	scene.set_physics_process(false)
	await process_frame
	await process_frame
	# In-memory rank override only; do not save test progression.
	scene.progression.ranks.cart = 3
	scene.player.position = scene.cart.position+Vector3(0,0,2)
	var items: Array = scene.rubbish.duplicate()
	for item in items:
		scene.pickup(item)
		scene.interact()
	assert(scene.cargo==8)
	for index in range(8):
		var support: float = scene.cart.global_position.y+.67 if index<6 else scene.highest_mesh_y(items[index-6],-INF)
		assert(absf(scene.lowest_mesh_y(items[index],INF)-support)<.001,"Cargo does not rest on support")
	var camera := Camera3D.new()
	scene.add_child(camera)
	camera.position = scene.cart.position+Vector3(2.6,3.6,2.8)
	camera.look_at(scene.cart.position+Vector3(0,.7,0))
	camera.current = true
	for tick in range(8):await process_frame
	scene.hud.hide()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../patrol_loaded_cart.png")
	print("CARGO VISUAL PASS: eight items loaded by interaction code, capture saved, user progress untouched")
	quit()
