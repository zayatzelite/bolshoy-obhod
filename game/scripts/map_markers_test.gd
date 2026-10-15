extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var map=preload("res://scripts/route_map.gd").new()
	root.add_child(map)
	map.size=Vector2(1000,480)
	var click:=InputEventMouseButton.new()
	click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;click.position=Vector2(300,240)
	map._gui_input(click)
	assert(map.waypoints[0].is_equal_approx(Vector2(.3,.5)))
	var destination:Vector3=map.unproject_position(map.waypoints[0])
	var saved: Array[Vector2]=map.waypoints
	map.free()
	map=preload("res://scripts/route_map.gd").new()
	map.waypoints=saved;root.add_child(map);map.size=Vector2(1200,600)
	assert((map.waypoints[0]*map.size).is_equal_approx(Vector2(360,300)))
	assert(map.unproject_position(map.waypoints[0]).is_equal_approx(destination),"Resize moved world waypoint")
	click.button_index=MOUSE_BUTTON_RIGHT;click.position=Vector2(360,300)
	map._gui_input(click)
	assert(saved.is_empty())
	for i in range(10):
		click.button_index=MOUSE_BUTTON_LEFT;click.position=Vector2(50+i*30,100)
		map._gui_input(click)
	assert(saved.size()==8)
	await process_frame
	print("MAP MARKERS PASS: normalized placement, reopen/resize persistence, nearest removal, eight-marker cap")
	quit()
