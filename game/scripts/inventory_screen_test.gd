extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.pickup(scene.rubbish[0])
	scene.stow_or_retrieve()
	var item: Node3D = scene.inventory[0]
	scene.inventory_menu()
	for tick in range(5):await process_frame
	assert(scene.overlay.size==Vector2(1280,720))
	var cards = scene.overlay.get_child(0).get_child(2)
	assert(cards.get_child_count()==3)
	assert(not cards.get_child(0).get_child(1).disabled)
	assert(cards.get_child(1).get_child(1).disabled)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../inventory_fullscreen_preview.png")
	cards.get_child(0).get_child(1).pressed.emit()
	assert(scene.held_item==item and scene.inventory.is_empty())
	print("INVENTORY SCREEN PASS: three icon cards, fullscreen bounds, empty slot locked, click retrieves correct item")
	quit()
