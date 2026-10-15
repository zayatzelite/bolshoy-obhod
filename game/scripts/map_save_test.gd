extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world=load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	world.waypoint_manifest="user://route_markers_test.json"
	world.map_waypoints.assign([Vector2(.2,.3),Vector2(.4,.8)])
	world.save_route_markers()
	world.map_waypoints.clear()
	world.load_route_markers()
	assert(world.map_waypoints.size()==2 and world.waypoint_active)
	assert(world.map_waypoints.back().is_equal_approx(Vector2(.4,.8)))
	var map=load("res://scripts/route_map.gd").new()
	assert(world.waypoint_destination.is_equal_approx(map.unproject_position(Vector2(.4,.8))))
	map.free()
	world.map_waypoints.clear();world.save_route_markers();world.load_route_markers()
	assert(not world.waypoint_active)
	print("MARKER SAVE PASS: normalized positions restored, compass destination restored, deletion persisted")
	quit()
