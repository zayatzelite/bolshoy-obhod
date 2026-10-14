extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.set_physics_process(false)
	await physics_frame
	await physics_frame
	var progress = preload("res://scripts/test_memory_progress.gd").new()
	progress.xp = 500
	scene.progression = progress
	scene.player.position = scene.bases[0]+Vector3(-2,.2,-1.5)
	scene.skill_menu()
	var tree = scene.overlay.get_child(0).get_child(0)
	assert(not tree.nodes[3].disabled and tree.nodes[4].disabled)
	tree.purchase("cart",3)
	assert(progress.ranks.cart==0)
	tree.nodes[3].pressed.emit()
	assert(progress.ranks.cart==1 and progress.points()==4 and progress.saves==1)
	assert(tree.nodes[3].disabled and not tree.nodes[4].disabled and tree.nodes[5].disabled)
	tree.nodes[4].pressed.emit()
	assert(progress.ranks.cart==2)
	scene.player.position = Vector3(0,.2,-40)
	tree.purchase("cart",3)
	assert(progress.ranks.cart==2 and progress.saves==2)
	print("SKILL PURCHASE PASS: rank skipping denied, next rank unlocks, trail bypass denied, save callback used; user progress untouched")
	quit()
