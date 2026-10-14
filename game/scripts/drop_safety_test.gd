extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var item: Node3D = scene.rubbish[0]
	scene.pickup(item)
	var wall := StaticBody3D.new()
	wall.position = Vector3(0,1,5)
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2,2,.3)
	collider.shape = shape;wall.add_child(collider);scene.add_child(wall)
	scene.player.set_physics_process(false)
	scene.player.position = Vector3(0,.2,6.25)
	await physics_frame
	await physics_frame
	scene.drop_held()
	assert(scene.held_item==item,"Drop placed item inside wall")
	wall.free()
	scene.player.position = Vector3(0,.2,23.8)
	scene.player.rotation.y = PI
	scene.drop_held()
	assert(scene.held_item==item,"Drop lost item outside safe perimeter")
	print("DROP SAFETY PASS: blocked wall and outside boundary retain held item")
	quit()
