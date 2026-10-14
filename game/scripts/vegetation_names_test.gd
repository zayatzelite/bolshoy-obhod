extends SceneTree
func _initialize() -> void:
	var scene = load("res://assets/patrol_location.glb").instantiate()
	var names := {}
	for node in scene.get_children():
		if node is MeshInstance3D and node.position.y<3:
			var title := str(node.name).split("_")[0].split(".")[0]
			if not names.has(title):names[title]=true;print(title)
	scene.free();quit()
