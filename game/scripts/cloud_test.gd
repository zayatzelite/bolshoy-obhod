extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	assert(scene.moving_clouds.size()==20)
	var cloud: Node3D = scene.moving_clouds[0]
	var relative: Vector3 = scene.moving_clouds[1].position-cloud.position
	for step in range(20):
		scene._process(600.0)
		assert((scene.moving_clouds[1].position-cloud.position).distance_to(relative)<.001)
		for index in range(20):
			assert(absf(scene.moving_clouds[index].position.x-scene.cloud_origins[index].x)<=12.001)
	print("CLOUD PASS: 200 minutes simulated, cloud parts preserve spacing, no wrapping jumps")
	quit()
