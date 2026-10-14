extends SceneTree
var checked := 0
func inspect_node(node: Node, scene: Node) -> void:
	if node is MeshInstance3D and ("Grass meadow detail" in str(node.name) or "Tall meadow grass clusters" in str(node.name)):
		for surface in range(node.mesh.get_surface_count()):
			var arrays = node.mesh.surface_get_arrays(surface)
			for index in arrays[Mesh.ARRAY_INDEX]:
				var p: Vector3 = node.global_transform*arrays[Mesh.ARRAY_VERTEX][index]
				assert(not scene.grass_excluded(p),"Grass intersects a protected structure footprint")
		checked+=1
	for child in node.get_children():inspect_node(child,scene)
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	assert(scene.grass_excluded(Vector3(-6,0,-40)))
	assert(scene.grass_excluded(Vector3(-9.4,0,-95)))
	assert(scene.grass_excluded(scene.bases[0]+Vector3(0,0,8)))
	assert(not scene.grass_excluded(Vector3(20,0,-40)))
	inspect_node(scene,scene)
	assert(checked==2)
	print("BASE GRASS PASS: both grass meshes have zero indexed vertices in both cabin/deck safety footprints")
	quit()
