extends "res://scripts/live_cart_main_test.gd"
var loaded: Array[Node3D] = []
func setup() -> void:
	super.setup()
	scene.progression = preload("res://scripts/test_memory_progress.gd").new()
	scene.player.dragging = false
	for index in range(4):
		var item: Node3D = scene.rubbish[0]
		loaded.append(item)
		scene.pickup(item)
		scene.interact()
	assert(scene.cargo==4 and scene.held_item==null)
	scene.player.dragging = true
var approaching := false
var approach_steps := 0
var aligned := false
func route_complete() -> void:approaching = true
func approach(delta: float) -> bool:
	approach_steps+=1
	var destination: Vector3 = scene.delivery_points[1]
	var target: Vector3 = destination+Vector3(0,0,1.8) if aligned else Vector3(destination.x,0,-160)
	var direction: Vector3 = target-scene.player.position
	direction.y = 0
	if direction.length()<.45 and not aligned:
		aligned = true
		return false
	if direction.length()<.45:
		scene.player.dragging = false
		scene.interact()
		assert(scene.cargo==0 and scene.delivered==4 and scene.session_xp==100)
		assert(scene.progression.xp==100 and scene.progression.saves==1)
		print("LOADED DELIVERY PASS: 159m route plus physical delivery approach, four cargo accepted, 100XP saved in memory")
		quit();return true
	direction = direction.normalized()
	scene.player.rotation.y = atan2(-direction.x,-direction.z)
	scene.player.velocity = Vector3(direction.x*2,scene.player.velocity.y-18*delta,direction.z*2)
	scene.player.move_and_slide()
	scene._physics_process(delta)
	if approach_steps>1200:
		push_error("Delivery approach blocked player=%s cart=%s" % [scene.player.position,scene.cart.position]);quit(1);return true
	return false
func _physics_process(delta: float) -> bool:
	if is_instance_valid(scene):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		assert(scene.cargo==4)
		for item in loaded:
			assert(is_instance_valid(item) and item.get_parent()==scene.cart)
			assert(is_finite(item.position.y) and item.visible)
	if approaching:return approach(delta)
	return super._physics_process(delta)
