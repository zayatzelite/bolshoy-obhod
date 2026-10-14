extends SceneTree
func inspect_node(node: Node) -> void:
	var title := str(node.name).to_lower()
	if node is MeshInstance3D and node.position.x < -7 and node.position.x > -12 and absf(node.position.z+40)<5:
		print(node.name," ",node.transform if node is Node3D else "", " bounds=",node.mesh.get_aabb() if node is MeshInstance3D else "")
	for child in node.get_children():inspect_node(child)
func _initialize() -> void:
	var scene = load("res://assets/patrol_location.glb").instantiate()
	inspect_node(scene)
	scene.free();quit()
