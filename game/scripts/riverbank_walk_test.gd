extends SceneTree
var scene: Node3D
var steps := 0
var progress := 0.0
func point(distance: float) -> Vector3:
	var z := 15-distance
	var x := (preload("res://scripts/riverbank.gd").edge(z)+55)/2
	return preload("res://scripts/riverbank.gd").vertex(x,z,.5)
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	scene.set_physics_process(false)
	scene.player.position = point(0)+Vector3(0,.3,0)
func _physics_process(delta: float) -> bool:
	if not is_instance_valid(scene):return false
	steps+=1
	var offset: Vector3 = point(progress+.4)-scene.player.position
	offset.y = 0
	if offset.length()<.45:progress+=.3
	var direction := offset.normalized()
	scene.player.velocity.x = direction.x*4
	scene.player.velocity.z = direction.z*4
	scene.player.velocity.y-=delta*18
	scene.player.move_and_slide()
	if progress>210:
		print("RIVERBANK WALK PASS: 210m dry shoreline traversed with player gravity and collision")
		quit();return true
	if steps>4500:
		push_error("Shoreline blocked at "+str(scene.player.position));quit(1);return true
	return false
