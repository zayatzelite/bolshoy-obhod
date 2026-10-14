extends "res://scripts/base_approach_walk_test.gd"
func setup() -> void:
	super.setup()
	scene.player.position=preload("res://scripts/shore_connector.gd").point(0)+Vector3(0,.3,0)
func _physics_process(delta: float) -> bool:
	if not is_instance_valid(scene):return false
	steps+=1
	var target: Vector3=preload("res://scripts/shore_connector.gd").point(minf(progress+.015,1))
	var offset: Vector3=target-scene.player.position
	offset.y=0
	if offset.length()<.4:progress+=.007
	var direction:=offset.normalized()
	scene.player.velocity=Vector3(direction.x*3,scene.player.velocity.y-delta*18,direction.z*3)
	scene.player.move_and_slide()
	if progress>=.995:
		print("SHORE CONNECTOR WALK PASS: base approach to dry beach with gravity and collision")
		quit();return true
	if steps>1500:
		push_error("Shore connector blocked at "+str(scene.player.position));quit(1);return true
	return false
