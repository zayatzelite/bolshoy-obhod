extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	var samples: Array[Vector3]=[]
	for i in range(397):
		var distance := -3.0+i*.5
		samples.append(Vector3(2.5*sin(distance*.035),0,-distance))
	for i in range(181):samples.append(preload("res://scripts/exploration_path.gd").point(20+i*.25))
	for i in range(257):
		samples.append(preload("res://scripts/base_approach.gd").point(i/256.0))
		samples.append(preload("res://scripts/shore_connector.gd").point(i/256.0))
	var checked := 0
	var conflicts: Array[String]=[]
	for object in scene.find_children("*","MeshInstance3D",true,false):
		var title:=str(object.name)
		if not object.is_visible_in_tree():continue
		if not (title.begins_with("Tree trunk") or title.begins_with("Pine layered crown") or title.begins_with("Scree boulder") or title.begins_with("Trail understory shrub")):continue
		checked+=1
		var bounds: AABB=object.global_transform*object.get_aabb()
		var footprint:=Rect2(Vector2(bounds.position.x,bounds.position.z),Vector2(bounds.size.x,bounds.size.z))
		for p in samples:
			var nearest:=Vector2(clampf(p.x,footprint.position.x,footprint.end.x),clampf(p.z,footprint.position.y,footprint.end.y))
			if nearest.distance_to(Vector2(p.x,p.z))<1.45:
				conflicts.append(title+" at "+str(p));break
	if not conflicts.is_empty():
		for conflict in conflicts:push_error(conflict)
		quit(1);return
	assert(checked>100)
	print("ALL ROUTES CLEARANCE PASS: ",samples.size()," independent route samples, ",checked," visible tree/shrub/boulder footprints, 1.45m clear radius")
	quit()
