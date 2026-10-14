extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	var flowers: Node3D
	for child in scene.get_children():
		if child.get_script()==preload("res://scripts/meadow_flowers.gd"):flowers=child
	assert(flowers!=null and flowers.flower_count>1000)
	assert(flowers.get_child_count()==3 and flowers.planting_points.size()==flowers.flower_count)
	var obstacles: Array[AABB] = []
	var shrubs := 0
	var trunks := 0
	for node in scene.get_node("Patrol_Location").get_children():
		if not node is MeshInstance3D:continue
		var title := str(node.name)
		if title.begins_with("Trail understory shrub"):shrubs+=1
		if title.begins_with("Tree trunk"):trunks+=1
		if title.begins_with("Trail understory shrub") or title.begins_with("Tree trunk") or title.begins_with("Scree boulder") or title.begins_with("Cliff fin") or title.begins_with("Trail limestone gallery"):
			obstacles.append((node.global_transform*node.get_aabb()).grow(.4))
	assert(shrubs>0 and trunks>0)
	for point in flowers.planting_points:
		for bounds in obstacles:
			assert(not(point.x>bounds.position.x and point.x<bounds.end.x and point.z>bounds.position.z and point.z<bounds.end.z),"Flower planting intersects obstacle footprint")
		assert(not scene.grass_excluded(point))
		assert(absf(point.x-2.5*sin(-point.z*.035))>=3.3)
	for child in flowers.get_children():assert(child.mesh.get_surface_count()==1)
	print("FLOWER PLACEMENT PASS: ",flowers.flower_count," decorative plants, three merged meshes, no protected footprints or main path centers")
	quit()
