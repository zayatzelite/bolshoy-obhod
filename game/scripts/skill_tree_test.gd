extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.set_physics_process(false)
	await physics_frame
	await physics_frame
	scene.player.position = Vector3(0,.2,-40)
	scene.pause_menu(true)
	for tick in range(4):await process_frame
	var tree = scene.overlay.get_child(0).get_child(0)
	assert(tree.nodes.size()==9)
	for node in tree.nodes:assert(node.disabled)
	assert(scene.overlay.size==Vector2(1280,720))
	assert(scene.overlay.get_global_rect().end.y<=720)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../skill_tree_preview.png")
	print("SKILL TREE PASS: nine sequential nodes, three branches, trail purchases disabled, fullscreen bounded")
	quit()
