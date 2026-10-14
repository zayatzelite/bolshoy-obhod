extends SceneTree
func _initialize() -> void:
	var bank = preload("res://scripts/riverbank.gd").build()
	root.add_child(bank)
	await process_frame
	var arrays = bank.mesh.surface_get_arrays(0)
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	for normal in normals:assert(normal.y>.8)
	assert(bank.mesh.get_aabb().size.z==260)
	assert(bank.get_child(0).multimesh.instance_count==420)
	for index in range(420):
		var at: Vector3 = bank.get_child(0).multimesh.get_instance_transform(index).origin
		assert(at.x>preload("res://scripts/riverbank.gd").edge(at.z) and at.x<55)
	bank.free()
	print("RIVERBANK MESH PASS: upward surface, 260m bank, 420 pebbles inside dry strip")
	quit()
