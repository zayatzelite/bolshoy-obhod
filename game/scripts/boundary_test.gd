extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for entry in [[Vector3(-47,2,-40),Vector3(-4,0,0)],[Vector3(51,2,-40),Vector3(4,0,0)],[Vector3(0,2,22),Vector3(0,0,4)],[Vector3(0,2,-208),Vector3(0,0,-4)]]:
		scene.player.position = entry[0]
		var collision = scene.player.move_and_collide(entry[1])
		if collision==null:
			push_error("Boundary missing at %s" % entry[0]);quit(1);return
	print("BOUNDARY PASS: four edges block player before terrain ends")
	quit()
