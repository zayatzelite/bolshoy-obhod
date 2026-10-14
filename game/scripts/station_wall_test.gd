extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.set_physics_process(false)
	await physics_frame
	await physics_frame
	scene.player.position = scene.bases[1]+Vector3(-2,.2,-1.5)
	assert(scene.at_upgrade_station())
	scene.player.position = scene.bases[1]+Vector3(-4.2,.2,-1.5)
	assert(not scene.at_upgrade_station(),"Station accessible through cabin wall")
	print("STATION WALL PASS: interior allowed, exterior within distance rejected by wall")
	quit()
