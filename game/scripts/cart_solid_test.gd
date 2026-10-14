extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.set_physics_process(false)
	scene.set_physics_process(false)
	scene.cart.position = Vector3(0,.2,-20)
	scene.player.position = Vector3(-2,.2,-20)
	await physics_frame
	await physics_frame
	var collision = scene.player.move_and_collide(Vector3(4,0,0))
	assert(collision!=null and collision.get_collider()==scene.cart,"Player crosses cart")
	assert(scene.player.position.x<-.5)
	assert(scene.player.get_collision_exceptions().is_empty())
	print("CART SOLID PASS: player horizontal sweep blocked by cart body, no mutual exceptions")
	quit()
