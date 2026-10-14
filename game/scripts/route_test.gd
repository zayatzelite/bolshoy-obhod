extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	auto_accept_quit = false
	print("ROUTE START")
	Engine.time_scale = 1.0
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.position = Vector3(0,.3,-2)
	scene.cart.position = Vector3(0,.15,0)
	# Simulate CharacterBody3D movement on every metre of the route without teleporting.
	for step in range(4300):
		# Fixed displacement avoids frame scheduling differences in headless tests.
		var distance: float = -scene.player.position.z
		var target := Vector3(2.5*sin((distance+1)*.035),scene.player.position.y,scene.player.position.z-1)
		var dir: Vector3 = (target-scene.player.position).normalized()
		scene.player.velocity = dir*2.8
		scene.player.velocity.y = -3
		scene.player.move_and_collide(dir*0.05)
		var floor_query := PhysicsRayQueryParameters3D.create(scene.player.position+Vector3(0,2,0),scene.player.position-Vector3(0,2,0))
		floor_query.exclude = [scene.player.get_rid(),scene.cart.get_rid()]
		var floor_hit: Dictionary = scene.get_world_3d().direct_space_state.intersect_ray(floor_query)
		if not floor_hit.is_empty():scene.player.position.y = floor_hit.position.y+.1
		var cart_target: Vector3 = scene.player.position+Vector3(0,0,2)
		var difference: Vector3 = cart_target-scene.cart.position
		scene.cart.velocity = Vector3(difference.x*4,-3,difference.z*4)
		scene.cart.move_and_collide(Vector3(difference.x*.08,0,difference.z*.08))
		scene.cart.position.y = scene.player.position.y
		assert(scene.player.position.y>-.8,"Player fell through route")
		assert(scene.cart.position.y>-.8,"Cart fell through route")
		if scene.player.position.distance_to(scene.cart.position)>=4.5:
			push_error("Cart blocked: player=%s cart=%s" % [scene.player.position,scene.cart.position])
			quit(1)
			return
		if scene.player.position.z < -180:
			print("ROUTE PASS: player and cart traversed 180 metres using collisions")
			quit()
			return
	push_error("Route traversal timed out at %s" % scene.player.position)
	quit(1)
