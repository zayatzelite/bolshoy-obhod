extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	var landscape: Node3D=scene.get_node("Patrol_Location")
	var removed:=0
	for trunk in landscape.get_children():
		if not trunk is MeshInstance3D or not str(trunk.name).begins_with("Tree trunk"):continue
		for crown in landscape.get_children():
			if crown is MeshInstance3D and str(crown.name).begins_with("Pine layered crown") and Vector2(crown.position.x-trunk.position.x,crown.position.z-trunk.position.z).length()<.8:
				assert(crown.visible==trunk.visible,"Orphan crown/trunk visibility mismatch")
		if trunk.has_meta("route_tree_group_removed"):removed+=1
	assert(removed>0)
	print("TREE GROUP PASS: no orphan crowns/trunks; ",removed," full trees hidden together")
	quit()
