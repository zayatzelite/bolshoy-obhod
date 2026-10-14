extends SceneTree
var scene: Node3D
var progress := 0.0
var steps := 0
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	scene.set_physics_process(false)
	scene.player.position = preload("res://scripts/base_approach.gd").point(0)+Vector3(0,.3,0)
func _physics_process(delta: float) -> bool:
	if not is_instance_valid(scene):return false
	steps+=1
	var target: Vector3 = preload("res://scripts/base_approach.gd").point(minf(progress+.015,1))
	var offset: Vector3 = target-scene.player.position
	offset.y=0
	if offset.length()<.4:progress+=.007
	var direction := offset.normalized()
	scene.player.velocity=Vector3(direction.x*3,scene.player.velocity.y-delta*18,direction.z*3)
	scene.player.move_and_slide()
	if progress>=.995:
		print("BASE APPROACH WALK PASS: curved connector traversed with gravity and collision")
		quit();return true
	if steps>1500:
		for index in range(scene.player.get_slide_collision_count()):print(scene.player.get_slide_collision(index).get_collider().get_path())
		push_error("Base approach blocked at "+str(scene.player.position));quit(1);return true
	return false
