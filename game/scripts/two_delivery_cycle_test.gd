extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	scene.set_physics_process(false)
	scene.progression = preload("res://scripts/test_memory_progress.gd").new()
	for batch in range(2):
		scene.player.position = Vector3(0,.2,-20)
		scene.cart.position = Vector3(0,.2,-22)
		for index in range(4):
			scene.pickup(scene.rubbish[0])
			scene.interact()
		assert(scene.cargo==4)
		scene.player.position = scene.delivery_points[batch]+Vector3(0,.2,1.5)
		scene.cart.position = scene.delivery_points[batch]+Vector3(0,.2,0)
		scene.interact()
		for tick in range(4):await process_frame
		assert(scene.cargo==0 and scene.delivered==(batch+1)*4)
		for child in scene.cart.get_children():assert(not child.name.begins_with("Cargo"))
		if batch==0:assert(not scene.results_shown and not is_instance_valid(scene.overlay))
	assert(scene.results_shown and is_instance_valid(scene.overlay))
	assert(scene.session_xp==200 and scene.progression.xp==200 and scene.progression.saves==2)
	assert(scene.rubbish.is_empty() and scene.held_item==null)
	print("TWO DELIVERY CYCLE PASS: 8 real litter objects loaded/accepted in two batches, 200 XP in memory, cargo cleared, results only after second batch; positions staged, not full traversal")
	quit()
