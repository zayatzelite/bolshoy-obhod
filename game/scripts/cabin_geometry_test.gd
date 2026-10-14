extends SceneTree
func inspect_node(node: Node) -> void:
	if node is MeshInstance3D and ("roof" in str(node.name).to_lower() or "gable" in str(node.name).to_lower() or "wall" in str(node.name).to_lower() or "deck" in str(node.name).to_lower()):print(node.name," transform=",node.transform," bounds=",node.mesh.get_aabb())
	for child in node.get_children():inspect_node(child)
func _initialize() -> void:
	var cabin = load("res://assets/ranger_base.glb").instantiate()
	inspect_node(cabin)
	cabin.free();quit()
