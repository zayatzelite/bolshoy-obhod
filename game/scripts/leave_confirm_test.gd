extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.pickup(scene.rubbish[0])
	var held: Node3D = scene.held_item
	scene.confirm_leave_patrol()
	for tick in range(4):await process_frame
	var rect: Rect2 = scene.overlay.get_global_rect()
	assert(rect.end.x<=1280 and rect.end.y<=720)
	var cancel: Button = scene.overlay.get_child(0).get_child(2)
	assert(cancel.text=="Остаться на тропе")
	cancel.pressed.emit()
	await process_frame
	assert(scene.held_item==held)
	assert(Input.mouse_mode==Input.MOUSE_MODE_CAPTURED)
	print("LEAVE CONFIRM PASS: warning bounded, cancellation preserves held item and resumes control")
	quit()
