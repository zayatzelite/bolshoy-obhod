extends SceneTree
func _initialize() -> void:
	var world = preload("res://scripts/world.gd").new()
	var positions: Array[Vector3] = []
	for slot in range(10):
		var pose: Transform3D = world.cargo_pose(slot)
		assert(absf(pose.origin.x)<=.3 and absf(pose.origin.z)<=.5)
		assert(pose.origin.y>=.8 and pose.origin.y<=1.1)
		for previous in positions:assert(pose.origin.distance_to(previous)>.25)
		positions.append(pose.origin)
	world.free()
	print("CARGO LAYOUT PASS: ten distinct positions within cart bed, two tiers, deterministic local rotations")
	quit()
