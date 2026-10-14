extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	scene.player.set_physics_process(false)
	scene.player.position = Vector3(25,.3,-30)
	for base in scene.bases:
		scene.cart.position = base+Vector3(0,.3,9.2)
		await physics_frame
		await physics_frame
		for step in range(150):
			scene.cart.velocity = Vector3(0,-3,-1.5)
			scene.cart.move_and_slide()
			await physics_frame
		assert(scene.cart.position.z<base.z+7.2,"Cart fails ramp entry "+str(scene.cart.position))
	print("DELIVERY RAMP PASS: cart physically enters both decks via sloped solid ramps")
	quit()
