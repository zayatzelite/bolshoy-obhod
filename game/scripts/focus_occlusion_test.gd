extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.set_physics_process(false)
	scene.player.position = Vector3(0,.2,-30)
	var item: Node3D = scene.rubbish[0]
	await process_frame
	await process_frame
	item.position = Vector3(0,1.85,-32)
	scene.player.camera.look_at(item.global_position)
	await physics_frame
	await physics_frame
	scene.update_focus()
	assert(scene.focused_item==item)
	var wall := StaticBody3D.new()
	wall.position = Vector3(0,1.85,-31)
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2,2,.2)
	collider.shape = shape
	wall.add_child(collider)
	scene.add_child(wall)
	await physics_frame
	await physics_frame
	scene.update_focus()
	assert(scene.focused_item==null,"Item selected through wall")
	wall.queue_free()
	await physics_frame
	await physics_frame
	scene.update_focus()
	assert(scene.focused_item==item)
	print("FOCUS OCCLUSION PASS: wall blocks targeting, removing wall restores targeting")
	quit()
