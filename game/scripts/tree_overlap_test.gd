extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	var removed := 0
	var background := 0
	for child in scene.get_children():
		if child.has_meta("trees_removed_from_rocks"):
			removed = child.get_meta("trees_removed_from_rocks")
			for piece in child.get_children():
				if piece.has_meta("rock_overlap_removed"):assert(not piece.visible)
		if child.has_meta("background_conifer"):
			background+=1
			assert(child.get_child_count()>1,"Background tree has no crown")
	assert(removed>0)
	assert(background==130)
	print("TREE OVERLAP PASS: ",removed," intersecting trees hidden with crowns; 130 background trees retain trunk and crown")
	quit()
