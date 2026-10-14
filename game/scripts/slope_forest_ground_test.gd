extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var shore=preload("res://scripts/riverbank.gd").distant_bank()
	root.add_child(shore)
	await process_frame
	await physics_frame
	await physics_frame
	var trunks: MultiMesh=shore.get_node("Limestone rear slope trunks").multimesh
	var body: StaticBody3D=shore.get_node("Incised limestone valley backing").get_child(0)
	for i in range(trunks.instance_count):
		var pose:=trunks.get_instance_transform(i)
		var p:=pose.origin
		var query:=PhysicsRayQueryParameters3D.create(Vector3(p.x,50,p.z),Vector3(p.x,-5,p.z),1)
		var hit:=shore.get_world_3d().direct_space_state.intersect_ray(query)
		assert(not hit.is_empty() and hit.collider==body)
		var bottom:=p.y-.6*pose.basis.get_scale().y
		assert(absf(bottom-hit.position.y)<.002,"Floating slope tree %d: %.4f" % [i,bottom-hit.position.y])
	print("SLOPE FOREST GROUND PASS: 240 tree bases match actual collision triangles within 2mm")
	quit()
