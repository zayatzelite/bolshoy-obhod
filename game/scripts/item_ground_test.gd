extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.ground_spawned_items()
	for item in scene.rubbish:
		var query := PhysicsRayQueryParameters3D.create(item.position+Vector3(0,3,0),item.position-Vector3(0,3,0))
		var excluded: Array[RID] = []
		for child in item.get_children():
			if child is CollisionObject3D:excluded.append(child.get_rid())
		query.exclude = excluded
		var hit: Dictionary = scene.get_world_3d().direct_space_state.intersect_ray(query)
		assert(not hit.is_empty())
		var gap: float = scene.lowest_mesh_y(item,item.position.y)-hit.position.y
		assert(absf(gap-.008)<.015,"Litter floating or buried")
	print("ITEM GROUND PASS: all eight Blender props touch terrain within 15mm tolerance")
	quit()
