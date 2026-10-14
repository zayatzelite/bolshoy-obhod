extends SceneTree
var scene: Node3D
var steps := 0
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	Engine.physics_ticks_per_second = 60
	Engine.time_scale = 1.0
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.set_physics_process(false)
	scene.set_physics_process(false)
	scene.player.position = Vector3(0,.3,-2)
	scene.cart.position = Vector3(0,.3,0)
func _physics_process(delta: float) -> bool:
	if not is_instance_valid(scene):return false
	steps+=1
	var d: float = -scene.player.position.z
	var target := Vector3(2.5*sin((d+1)*.035),scene.player.position.y,scene.player.position.z-1)
	var dir: Vector3 = (target-scene.player.position).normalized()
	scene.player.velocity.x = dir.x*2.8
	scene.player.velocity.z = dir.z*2.8
	scene.player.velocity.y -= 18*delta
	scene.player.move_and_slide()
	var difference: Vector3 = scene.player.position+Vector3(0,0,2)-scene.cart.position
	scene.cart.velocity = Vector3(difference.x*4,scene.cart.velocity.y-18*delta,difference.z*4)
	scene.cart.move_and_slide()
	if scene.player.position.y < -.8 or scene.cart.position.y < -.8 or difference.length()>4.5:
		push_error("Physics route failed: player=%s cart=%s" % [scene.player.position,scene.cart.position]);quit(1);return true
	if d>160:
		print("PHYSICS ROUTE PASS: 160m using gravity and move_and_slide, no height correction")
		quit();return true
	if steps>5000:
		push_error("Physics route timeout at %s" % scene.player.position);quit(1);return true
	return false
