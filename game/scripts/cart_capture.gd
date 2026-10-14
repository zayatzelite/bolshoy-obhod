extends SceneTree
var scene: Node3D
var ticks := 0
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.set_physics_process(false)
	scene.player.position = Vector3(2.8,.4,6.4)
	scene.player.camera.look_at(scene.cart.global_position+Vector3(0,.7,0))
	scene.message_timer = 0
func _process(_delta: float) -> bool:
	if not is_instance_valid(scene):return false
	ticks+=1
	if ticks==8:
		root.get_texture().get_image().save_png("res://../patrol_cart_preview.png")
		print("CART CAPTURE PASS")
		quit()
	return false
