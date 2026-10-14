extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.skill_menu()
	var actions = scene.overlay.get_child(0).get_child(1)
	actions.get_child(0).pressed.emit()
	for tick in range(4):await process_frame
	assert(scene.overlay.get_child(0).get_child(0).text=="ЖУРНАЛ ОБХОДА")
	assert(scene.overlay.size==Vector2(1280,720))
	assert(scene.overlay.get_child(0).get_child(2).get_child(0).get_child(0).text.contains("подтверждённые"))
	scene.overlay.get_child(0).get_child(3).pressed.emit()
	assert(scene.overlay.get_child(0).get_child(0).nodes.size()==9)
	print("JOURNAL NAVIGATION PASS: skills to journal and back, fullscreen, missing verified plant data explicit")
	quit()
