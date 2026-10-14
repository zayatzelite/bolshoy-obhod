extends "res://scripts/riverbank_cart_test.gd"
var loaded: Array[Node3D] = []
func setup() -> void:
	super.setup()
	scene.progression = preload("res://scripts/test_memory_progress.gd").new()
	scene.player.dragging = false
	for index in range(4):
		var item: Node3D = scene.rubbish[0]
		loaded.append(item)
		scene.pickup(item)
		scene.interact()
	assert(scene.cargo==4 and scene.held_item==null)
	scene.player.dragging = true
func route_complete() -> void:
	assert(scene.cargo==4)
	for item in loaded:
		assert(is_instance_valid(item) and item.get_parent()==scene.cart and str(item.name).begins_with("Cargo"))
	assert(scene.progression.saves==0)
	print("LOADED RIVERBANK CART PASS: four real items retained through 159m production towing; no progress writes")
	quit()
