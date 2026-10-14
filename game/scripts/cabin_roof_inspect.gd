extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	for node in scene.find_children("*","MeshInstance3D",true,false):
		if "roof" in node.name.to_lower() or "gable" in node.name.to_lower():
			print(node.get_path()," local=",node.get_aabb()," transform=",node.global_transform)
	quit()
