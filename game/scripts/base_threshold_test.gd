extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world=load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	world.player.set_physics_process(false)
	var count:=0
	var signs:=0
	for node in world.get_children():
		if node.has_meta("deck_threshold"):
			count+=1
			assert(node.mesh.size.is_equal_approx(Vector3(8,.16,.42)))
			assert(node.get_child_count()>0)
		if node.has_meta("delivery_sign"):
			signs+=1
			assert(not node.no_depth_test)
	assert(count==2 and signs==2)
	for base in world.bases:
		var query:=PhysicsRayQueryParameters3D.create(base+Vector3(0,2,3.70),base+Vector3(0,-1,3.70))
		await physics_frame
		assert(not world.get_world_3d().direct_space_state.intersect_ray(query).is_empty())
	print("BASE THRESHOLD PASS: two full-width bridges with collision, two depth-tested delivery signs")
	quit()
