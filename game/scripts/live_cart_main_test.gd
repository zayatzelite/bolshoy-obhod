extends "res://scripts/live_cart_route_test.gd"
func branch_x(d: float) -> float:return 2.5*sin(d*.035)
func setup() -> void:
	super.setup()
	scene.player.position = Vector3(branch_x(2),1,-2)
	scene.cart.position = Vector3(branch_x(4),1,-4)
func route_complete() -> void:
	print("LIVE MAIN CART PASS: 159m to destination approach using production cart movement")
	quit()

func _physics_process(delta: float) -> bool:
	if not is_instance_valid(scene):return false
	steps+=1
	var d: float = -scene.player.position.z
	var target := Vector3(branch_x(d+1),scene.player.position.y,scene.player.position.z-1)
	var dir: Vector3 = (target-scene.player.position).normalized()
	scene.player.rotation.y = atan2(-dir.x,-dir.z)
	scene.player.velocity.x = dir.x*2.8
	scene.player.velocity.z = dir.z*2.8
	scene.player.velocity.y -= 18*delta
	scene.player.move_and_slide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	scene._physics_process(delta)
	assert(scene.session_seconds>0,"Production physics did not run")
	assert(scene.cart.position.distance_to(scene.player.position)<4.1,"Cart did not follow player")
	if not scene.player.dragging or scene.player.position.y < -.8 or scene.cart.position.y < -.8:
		push_error("Live main cart failed: player=%s cart=%s" % [scene.player.position,scene.cart.position]);quit(1);return true
	if d>161:
		route_complete()
		return false
	if steps>5500 or (steps>1200 and d<18):
		for index in range(scene.player.get_slide_collision_count()):print("PLAYER CONTACT ",scene.player.get_slide_collision(index).get_collider().get_path()," normal=",scene.player.get_slide_collision(index).get_normal()," target-d=",d," cart=",scene.cart.position)
		for index in range(scene.cart.get_slide_collision_count()):print("CART CONTACT ",scene.cart.get_slide_collision(index).get_collider().get_path()," normal=",scene.cart.get_slide_collision(index).get_normal()," dragging=",scene.player.dragging," velocity=",scene.cart.velocity)
		push_error("Live main cart timeout at %s" % scene.player.position);quit(1);return true
	return false
