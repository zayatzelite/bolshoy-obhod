extends SceneTree
var scene: Node3D
var steps := 0
func branch_x(d: float) -> float:
	return 2.5*sin(d*.035)-22*sin((d-55)*PI/100)
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	scene.player.set_physics_process(false)
	scene.set_physics_process(false)
	scene.player.position = Vector3(branch_x(56),1,-56)
	scene.cart.position = Vector3(branch_x(58),1,-58)
	scene.player.dragging = true
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
		push_error("Live cart failed: player=%s cart=%s" % [scene.player.position,scene.cart.position]);quit(1);return true
	if d>154:
		print("LIVE CART PASS: full scenic branch using production cart movement, gravity and collision")
		quit();return true
	if steps>4000:
		push_error("Live cart timeout at %s" % scene.player.position);quit(1);return true
	return false
