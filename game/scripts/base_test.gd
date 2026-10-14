extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for at in scene.bases:
		scene.player.position = at+Vector3(0,.25,7)
		for i in range(150):
			scene.player.move_and_collide(Vector3(0,0,-.05))
		if scene.player.position.z > at.z+.5:
			push_error("Base door blocked at %s" % scene.player.position)
			quit(1)
			return
		scene.player.position = at+Vector3(-2,.25,-1.5)
		scene.interact()
		assert(is_instance_valid(scene.overlay),"Board interaction missing")
		scene.overlay.free()
	print("BASE PASS: both doors traversable and both upgrade boards interactive")
	quit()
