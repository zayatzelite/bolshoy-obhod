extends SceneTree
var scene: Node3D
var ticks := 0
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	scene.set_physics_process(false)
	scene.player.set_physics_process(false)
	scene.player.position = Vector3(0,.3,-20)
	scene.cart.position = Vector3(0,.3,-22)
	scene.player.dragging = true
	var wall := StaticBody3D.new()
	wall.position = Vector3(0,2,-24)
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(10,4,.3)
	collider.shape = shape
	wall.add_child(collider)
	scene.add_child(wall)
func _physics_process(delta: float) -> bool:
	if not is_instance_valid(scene):return false
	ticks+=1
	if ticks>3:
		if ticks<70:scene.player.move_and_collide(Vector3(0,0,-.05))
		else:scene.player.position.z = -30
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		var before: Vector3 = scene.cart.position
		var wheel_before: Basis = scene.wheels[0].basis
		scene._physics_process(delta)
		var horizontal := Vector2(scene.cart.position.x-before.x,scene.cart.position.z-before.z).length()
		if horizontal<.00001:assert(scene.wheels[0].basis.is_equal_approx(wheel_before),"Stationary cart wheels rotated")
		assert(scene.cart.position.z > -23.3,"Cart passed through wall")
		if not scene.player.dragging:
			print("CART OBSTACLE PASS: wall blocks cart and distance safety releases it")
			quit();return true
	if ticks>200:
		push_error("Cart safety failed to release");quit(1);return true
	return false
