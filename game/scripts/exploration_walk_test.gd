extends SceneTree
var scene: Node3D
var steps := 0
var progress := 20.0
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	scene.set_physics_process(false)
	scene.player.position = preload("res://scripts/exploration_path.gd").point(20)+Vector3(0,.3,0)
func _physics_process(delta: float) -> bool:
	if not is_instance_valid(scene):return false
	steps+=1
	var target: Vector3 = preload("res://scripts/exploration_path.gd").point(progress+.4)
	var offset: Vector3 = target-scene.player.position
	offset.y = 0
	if offset.length()<.45:progress+=.3
	var dir := offset.normalized()
	scene.player.velocity.x = dir.x*4
	scene.player.velocity.z = dir.z*4
	scene.player.velocity.y-=delta*18
	scene.player.move_and_slide()
	if progress>64.4:
		print("EXPLORATION WALK PASS: full third loop traversed with player gravity and collision")
		quit();return true
	if steps>1500:
		for index in range(scene.player.get_slide_collision_count()):
			var collision = scene.player.get_slide_collision(index)
			print("BLOCK CONTACT ",collision.get_collider().get_path()," normal=",collision.get_normal())
		push_error("Exploration blocked at "+str(scene.player.position));quit(1);return true
	return false
