extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_physics_process(false)
	scene.player.set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var first: Node3D = scene.rubbish[0]
	scene.pickup(first)
	scene.player.position = scene.cart.position+Vector3(0,0,1)
	scene.interact()
	assert(scene.cargo==1)
	var held: Node3D = scene.rubbish[0]
	scene.pickup(held)
	scene.cart.position = Vector3(-20,0,-90)
	scene.cart.velocity = Vector3(8,-4,8)
	scene.player.position = Vector3(0,-6,-90)
	scene.player.last_fall = -30
	scene.player._physics_process(1.0/60.0)
	assert(scene.player.position.distance_to(Vector3(0,.2,8))<.1)
	assert(scene.cart.position.distance_to(Vector3(1,.2,4))<.1)
	assert(scene.cart.velocity==Vector3.ZERO)
	assert(scene.cargo==1 and scene.held_item==held)
	assert(scene.player.health==100 and scene.player.last_fall==0)
	assert(first.get_parent()==scene.cart)
	print("RECOVERY PASS: evacuation returns cart, preserves cargo and held item, clears fall damage and velocity")
	quit()
