extends SceneTree
func _initialize() -> void:
	var scene = load("res://assets/patrol_location.glb").instantiate()
	for node in scene.get_children():
		if node is MeshInstance3D and (str(node.name).begins_with("Cliff fin 00") or str(node.name).begins_with("Cliff fin 20") or str(node.name).begins_with("Cliff fin 44")):
			print(node.name," transform=",node.transform," bounds=",node.mesh.get_aabb())
	scene.free();quit()
