extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await physics_frame
	await physics_frame
	var bank: MeshInstance3D = scene.get_node("Sandy riverbank")
	var body: StaticBody3D
	for child in bank.get_children():
		if child is StaticBody3D:body=child
	assert(body!=null)
	var samples := 0
	for index in range(100):
		var z := 20.0-index*2.3
		var x := (preload("res://scripts/riverbank.gd").edge(z)+55)/2
		var query := PhysicsRayQueryParameters3D.create(Vector3(x,5,z),Vector3(x,-2,z),1)
		var hit = scene.get_world_3d().direct_space_state.intersect_ray(query)
		assert(not hit.is_empty() and hit.collider==body,"Dry bank collision obstructed or missing")
		samples+=1
	print("RIVERBANK COLLISION PASS: ",samples," dry-strip surface hits")
	quit()
