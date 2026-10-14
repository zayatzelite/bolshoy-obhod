extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	scene.set_physics_process(false)
	await physics_frame
	await physics_frame
	scene.player.position = scene.delivery_points[0]+Vector3(0,.2,0)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	scene.cargo = 0
	scene._process(.01)
	assert(not scene.prompt.text.contains("сдать груз"))
	scene.cargo = 1
	scene._process(.01)
	assert(scene.prompt.text=="E — сдать груз на базе")
	print("DELIVERY PROMPT PASS: empty cart has no unload prompt, loaded cart does")
	quit()
