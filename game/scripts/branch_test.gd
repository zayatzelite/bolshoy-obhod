extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.position = Vector3(2.5*sin(55*.035),.35,-55)
	scene.cart.position = scene.player.position+Vector3(0,0,2)
	for i in range(1,2001):
		var d := 55+i*.05
		var x := -22*sin((d-55)/100*PI)+2.5*sin(d*.035)
		var target := Vector3(x,scene.player.position.y,-d)
		scene.player.move_and_collide(target-scene.player.position)
		if Vector2(scene.player.position.x-target.x,scene.player.position.z-target.z).length()>.3:
			push_error("Branch obstruction at %s" % scene.player.position);quit(1);return
		var query := PhysicsRayQueryParameters3D.create(scene.player.position+Vector3(0,3,0),scene.player.position-Vector3(0,3,0))
		query.exclude = [scene.player.get_rid(),scene.cart.get_rid()]
		var hit: Dictionary = scene.get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty():push_error("Branch missing ground");quit(1);return
		scene.player.position.y = hit.position.y+.1
		var difference: Vector3 = scene.player.position+Vector3(0,0,2)-scene.cart.position
		scene.cart.move_and_collide(Vector3(difference.x*.1,0,difference.z*.1))
		scene.cart.position.y = scene.player.position.y
		if scene.cart.position.distance_to(scene.player.position)>4.5:
			push_error("Cart blocked on branch");quit(1);return
	print("BRANCH PASS: player and cart traversed entire 100m scenic loop")
	quit()
