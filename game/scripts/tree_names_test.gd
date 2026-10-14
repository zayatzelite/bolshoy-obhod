extends SceneTree
func _initialize() -> void:
	var scene = load("res://assets/patrol_location.glb").instantiate()
	for child in scene.get_children():
		if "trunk" in str(child.name).to_lower():print(child.name," ",child.position)
	scene.free();quit()
