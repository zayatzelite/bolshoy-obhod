extends SceneTree
func _initialize() -> void:
	var scene = load("res://assets/patrol_location.glb").instantiate()
	for child in scene.get_children():
		if child is MeshInstance3D and child.mesh.get_aabb().size.y>8:print(child.name)
	scene.free()
	quit()
