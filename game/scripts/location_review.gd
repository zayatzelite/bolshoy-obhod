extends SceneTree
var scene: Node3D
var ticks := 0
var index := 0
var positions := [Vector3(-8,.25,11),Vector3(0,.3,-54),Vector3(-21,.7,-90),Vector3(5,.3,-160)]
var paths := ["patrol_start_review.png","patrol_fork_review.png","patrol_rocks_review.png","patrol_destination_review.png"]
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.message_timer = 0
	scene.player.position = positions[0]
	scene.player.camera.rotation = Vector3(-.08,0,0)
func _process(_delta: float) -> bool:
	if not is_instance_valid(scene):return false
	ticks+=1
	if ticks%8==0:
		root.get_texture().get_image().save_png("res://../"+paths[index])
		index+=1
		if index==positions.size():
			print("LOCATION REVIEW PASS: four distinct gameplay viewpoints captured")
			quit();return true
		scene.player.position = positions[index]
	return false
