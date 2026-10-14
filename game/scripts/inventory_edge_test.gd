extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var items: Array = scene.rubbish.duplicate()
	for i in range(3):
		scene.pickup(items[i]);scene.stow_or_retrieve()
	assert(scene.inventory.size()==3 and scene.held_item==null)
	scene.pickup(items[3]);scene.stow_or_retrieve()
	assert(scene.inventory.size()==3 and scene.held_item==items[3],"Full inventory lost fourth item")
	scene.player.position = Vector3(0,.2,-5)
	scene.drop_held()
	assert(scene.held_item==null and scene.rubbish.has(items[3]))
	assert(scene.lowest_mesh_y(items[3],items[3].position.y)>=-.05,"Dropped item below terrain")
	scene.pickup(items[3])
	assert(scene.held_item==items[3])
	scene.inventory_menu()
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE;escape.pressed = true
	scene._unhandled_input(escape)
	await process_frame
	assert(not is_instance_valid(scene.overlay))
	assert(Input.mouse_mode==Input.MOUSE_MODE_CAPTURED)
	print("INVENTORY EDGE PASS: capacity, fourth-item retention, grounded drop, pickup, Escape resume")
	quit()
