extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var clouds := preload("res://scripts/soft_clouds.gd").new()
	root.add_child(clouds)
	assert(clouds.groups.size()==16)
	for group in clouds.groups:
		assert(group.get_child_count()==7)
		for puff in group.get_children():assert(puff.scale.y>=1.3)
	for step in range(1200):clouds._process(1)
	for index in range(16):assert(clouds.groups[index].position.distance_to(clouds.origins[index])<=10.001)
	print("SOFT CLOUDS PASS: sixteen seven-puff groups, volumetric proportions, continuous bounded drift")
	quit()
