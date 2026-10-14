extends SceneTree
var scene: Node3D
var progress := 0.0
var steps := 0
var approaching := false
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene=load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.progression=preload("res://scripts/test_memory_progress.gd").new()
	scene.player.set_physics_process(false)
	scene.set_physics_process(false)
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	scene.player.position=preload("res://scripts/base_approach.gd").point(0)+Vector3(0,.4,0)
	scene.cart.position=preload("res://scripts/base_approach.gd").point(.06)+Vector3(0,.4,0)
	for i in range(4):
		scene.pickup(scene.rubbish[0])
		scene.interact()
	assert(scene.cargo==4)
	scene.player.dragging=true
func _physics_process(delta: float) -> bool:
	if not is_instance_valid(scene):return false
	steps+=1
	var target: Vector3=scene.delivery_points[1]+Vector3(0,0,1.8) if approaching else preload("res://scripts/base_approach.gd").point(minf(progress+.02,1))
	var offset: Vector3=target-scene.player.position
	offset.y=0
	if offset.length()<.4:
		if approaching:
			scene.player.dragging=false
			scene.interact()
			assert(scene.cargo==0 and scene.delivered==4 and scene.session_xp==100)
			print("RIVERSIDE BASE DELIVERY PASS: curved route, four cargo delivered, 100XP in memory")
			quit();return true
		progress+=.009
		if progress>=.99:approaching=true
	var direction:=offset.normalized()
	scene.player.rotation.y=atan2(-direction.x,-direction.z)
	scene.player.velocity=Vector3(direction.x*2,scene.player.velocity.y-delta*18,direction.z*2)
	scene.player.move_and_slide()
	scene._physics_process(delta)
	if not scene.player.dragging or steps>2200:
		push_error("New base delivery blocked: player=%s cart=%s" % [scene.player.position,scene.cart.position]);quit(1);return true
	return false
