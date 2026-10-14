extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	scene.set_physics_process(false)
	await physics_frame
	await physics_frame
	for z in [-40.0,-95.0,-155.0]:
		scene.player.position = Vector3(-11,.2,z)
		var collision = scene.player.move_and_collide(Vector3(3,0,0))
		assert(collision!=null and collision.get_collider().has_meta("waste_bin_collision"))
		assert(scene.player.position.x<-9.7)
	print("BIN COLLISION PASS: player blocked by all three detailed bin colliders")
	quit()
