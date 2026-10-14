extends SceneTree
func _initialize() -> void:
	var scene = load("res://assets/patrol_location.glb").instantiate()
	for node in scene.get_children():
		if "grass" in str(node.name).to_lower():print(node.name," ",node.transform)
	scene.free();quit()
