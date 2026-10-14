extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var shore=preload("res://scripts/riverbank.gd").distant_bank()
	root.add_child(shore)
	await process_frame
	var hill: MeshInstance3D=shore.get_node("Far shore rolling hills")
	hill.create_trimesh_collision()
	await physics_frame
	await physics_frame
	var hill_body: StaticBody3D=hill.get_child(0)
	var crowns: MultiMesh=shore.get_node("Far shore forest silhouette").multimesh
	var trunks: MultiMesh=shore.get_node("Far shore tree trunks").multimesh
	assert(crowns.instance_count==180 and trunks.instance_count==180)
	for i in range(180):
		var crown:=crowns.get_instance_transform(i)
		var trunk:=trunks.get_instance_transform(i)
		assert(is_equal_approx(crown.origin.x,trunk.origin.x) and is_equal_approx(crown.origin.z,trunk.origin.z))
		var scale_value:=trunk.basis.get_scale().y
		if trunk.origin.z>=-171 and trunk.origin.z<=-25:
			assert(trunk.origin.x-1.3*scale_value>169,"Far hill tree crown intersects rock slope zone")
		var p:=trunk.origin
		var query:=PhysicsRayQueryParameters3D.create(Vector3(p.x,50,p.z),Vector3(p.x,-5,p.z),1)
		var excluded: Array[RID]=[]
		for body in shore.find_children("*","CollisionObject3D",true,false):
			if body!=hill_body:excluded.append(body.get_rid())
		query.exclude=excluded
		var hit:=shore.get_world_3d().direct_space_state.intersect_ray(query)
		assert(not hit.is_empty() and hit.collider==hill_body)
		assert(absf(trunk.origin.y-.6*scale_value-hit.position.y)<.002)
		assert(crown.origin.y-2.5*scale_value<trunk.origin.y+.6*scale_value)
	print("FAR FOREST PASS: 180 matched crowns/trunks, grounded bases, overlapping canopy joins")
	quit()
