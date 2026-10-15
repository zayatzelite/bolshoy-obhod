extends SceneTree
var scene: Node3D
var ticks := 0
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.waypoint_manifest="user://route_map_test.json"
	scene.map_waypoints.clear()
	scene.waypoint_active=false
	scene.map_menu()
func _process(_delta: float) -> bool:
	if not is_instance_valid(scene):return false
	ticks+=1
	if ticks==8:
		var rect: Rect2 = scene.overlay.get_global_rect()
		assert(rect.end.x<=1280 and rect.end.y<=720)
		var map = scene.overlay.get_child(0).get_child(2)
		assert(map.cart_position.is_equal_approx(scene.cart.position))
		assert(map.plant_names.size()==21 and map.plant_points.size()==21)
		assert(is_equal_approx(map.player_heading,scene.player.rotation.y))
		assert(not scene.hud.visible)
		var click:=InputEventMouseButton.new()
		click.button_index=MOUSE_BUTTON_LEFT
		click.pressed=true
		click.position=map.size*Vector2(.4,.5)
		map._gui_input(click)
		assert(scene.map_waypoints.size()==1)
		assert(scene.waypoint_active)
		assert(scene.navigation_destination().is_equal_approx(map.unproject_position(Vector2(.4,.5))))
		var roundtrip:Vector3=map.unproject_position(map.project_position(scene.player.position)/map.size)
		assert(Vector2(roundtrip.x,roundtrip.z).distance_to(Vector2(scene.player.position.x,scene.player.position.z))<.01)
		scene.overlay.free()
		scene.map_menu()
		var reopened=scene.overlay.get_child(0).get_child(2)
		assert(reopened.waypoints.size()==1 and reopened.waypoints[0].is_equal_approx(Vector2(.4,.5)))
		click.button_index=MOUSE_BUTTON_RIGHT
		click.position=reopened.size*Vector2(.4,.5)
		reopened._gui_input(click)
		assert(not scene.waypoint_active and scene.map_waypoints.is_empty())
		assert(scene.navigation_destination().is_equal_approx(scene.delivery_points[1]))
		root.get_texture().get_image().save_png("res://../patrol_map_preview.png")
		print("MAP PASS: schematic and return button bounded by viewport")
		quit()
	return false
