extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var item: Node3D = scene.rubbish[0]
	scene.pickup(item)
	scene.stow_or_retrieve()
	scene.inventory_menu()
	for i in range(8):await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../patrol_inventory_preview.png")
	var column = scene.overlay.get_child(0)
	for child in column.get_children():
		if child is Button and child.text.contains("взять в руки"):
			child.pressed.emit()
			break
	assert(scene.held_item==item and scene.inventory.is_empty(),"Inventory selection failed")
	await process_frame
	assert(not is_instance_valid(scene.overlay),"Inventory didn't close")
	print("INVENTORY PASS: named item selected, retrieved and window closed")
	quit()
