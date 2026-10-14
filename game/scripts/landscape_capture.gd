extends SceneTree
var scene: Node3D
var ticks := 0
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.position = Vector3(-21,.7,-90)
	scene.player.camera.rotation = Vector3(-.08,0,0)
	scene.message_timer = 0
func _process(_delta: float) -> bool:
	if not is_instance_valid(scene):return false
	ticks+=1
	if ticks==3:
		root.get_texture().get_image().save_png("res://../patrol_landscape_preview.png")
		print("LANDSCAPE CAPTURE PASS")
		quit()
	return false
