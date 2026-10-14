extends SceneTree
var scene: Node3D
var ticks := 0
var index := 0
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.set_physics_process(false)
	scene.message_timer = 0
	place()
func place() -> void:
	scene.player.position = scene.bases[index]+Vector3(1.5,.25,2)
	scene.player.camera.look_at(scene.bases[index]+Vector3(-1.4,1.5,-1.7))
func _process(_delta: float) -> bool:
	if not is_instance_valid(scene):return false
	ticks+=1
	if ticks%8==0:
		root.get_texture().get_image().save_png("res://../patrol_interior_review_%d.png" % index)
		index+=1
		if index==2:
			print("INTERIOR CAPTURE PASS: both furnished bases captured")
			quit();return true
		place()
	return false
