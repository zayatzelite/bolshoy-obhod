extends SceneTree
func _initialize() -> void:
	var base = load("res://assets/ranger_base.glb").instantiate()
	show_names(base)
	base.free()
	quit()
func show_names(node: Node) -> void:
	if node is MeshInstance3D:
		print(node.name)
	for child in node.get_children():show_names(child)
