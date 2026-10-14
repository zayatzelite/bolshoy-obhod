extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.position = Vector3(0,.2,8)
	scene.cargo = 0
	assert(scene.navigation_destination()==scene.delivery_points[1])
	scene.cargo = 1
	assert(scene.navigation_destination()==scene.delivery_points[0])
	scene._process(.01)
	assert(scene.hud.navigation_label.text.contains("СДАЧА"))
	scene.player.position = Vector3(0,.2,-145)
	assert(scene.navigation_destination()==scene.delivery_points[1])
	scene.cargo = 0
	scene._process(.01)
	assert(scene.hud.navigation_label.text.contains("БАЗА"))
	print("NAVIGATION PASS: empty cart points to destination, loaded cart to nearest delivery area")
	quit()
