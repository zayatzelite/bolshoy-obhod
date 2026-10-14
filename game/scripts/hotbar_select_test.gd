extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	for index in range(3):
		scene.pickup(scene.rubbish[0])
		scene.stow_or_retrieve()
	var first: Node3D = scene.inventory[0]
	var second: Node3D = scene.inventory[1]
	scene.select_hotbar(0)
	assert(scene.held_item==first and scene.inventory.size()==2)
	scene.select_hotbar(0)
	assert(scene.held_item==second and scene.inventory[0]==first)
	assert(not first.visible and second.visible)
	scene.select_hotbar(2)
	assert(scene.held_item==second and scene.inventory.size()==2)
	scene.player.dragging = true
	scene.select_hotbar(0)
	assert(scene.held_item==second)
	print("HOTBAR SELECT PASS: retrieves selected slot, swaps occupied hand, no duplication, empty/dragging selection ignored")
	quit()
