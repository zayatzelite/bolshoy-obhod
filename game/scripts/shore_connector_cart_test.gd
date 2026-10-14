extends SceneTree
var scene: Node3D
var progress := 0.0
var steps := 0
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene=load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.progression=preload("res://scripts/test_memory_progress.gd").new()
	scene.player.set_physics_process(false)
	scene.set_physics_process(false)
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	scene.player.position=preload("res://scripts/shore_connector.gd").point(0)+Vector3(0,.4,0)
	scene.cart.position=preload("res://scripts/shore_connector.gd").point(.07)+Vector3(0,.4,0)
	for i in range(4):
		scene.pickup(scene.rubbish[0])
		scene.interact()
	assert(scene.cargo==4)
	scene.player.dragging=true
func _physics_process(delta: float) -> bool:
	if not is_instance_valid(scene):return false
	steps+=1
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	var target: Vector3=preload("res://scripts/shore_connector.gd").point(minf(progress+.025,1))
	var offset: Vector3=target-scene.player.position
	offset.y=0
	if offset.length()<.4:progress+=.009
	var direction:=offset.normalized()
	scene.player.rotation.y=atan2(-direction.x,-direction.z)
	scene.player.velocity=Vector3(direction.x*2,scene.player.velocity.y-delta*18,direction.z*2)
	scene.player.move_and_slide()
	scene._physics_process(delta)
	assert(scene.cargo==4)
	if not scene.player.dragging or scene.cart.position.y<-.8 or steps>2000:
		push_error("Shore connector cart blocked player=%s cart=%s" % [scene.player.position,scene.cart.position]);quit(1);return true
	if progress>=.99:
		assert(scene.cart.position.distance_to(scene.player.position)<4.1)
		assert(scene.progression.saves==0)
		print("SHORE CONNECTOR CART PASS: four items, production towing to beach, no grip loss or saves")
		quit();return true
	return false
