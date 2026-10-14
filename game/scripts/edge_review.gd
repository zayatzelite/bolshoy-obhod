extends SceneTree
var scene: Node3D
var ticks := 0
var index := 0
var positions := [Vector3(-43,1,-90),Vector3(47,1,-90),Vector3(0,1,19),Vector3(0,1,-201)]
var targets := [Vector3(-70,2,-90),Vector3(75,2,-90),Vector3(0,2,45),Vector3(0,2,-240)]
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.set_physics_process(false)
	scene.message_timer = 0
	place()
func place() -> void:
	scene.player.position = positions[index]
	scene.player.camera.look_at(targets[index])
func _process(_delta: float) -> bool:
	if not is_instance_valid(scene):return false
	ticks+=1
	if ticks%8==0:
		root.get_texture().get_image().save_png("res://../patrol_edge_review_%d.png" % index)
		index+=1
		if index==4:
			print("EDGE CAPTURE PASS: four perimeter viewpoints captured")
			quit();return true
		place()
	return false
