extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	scene.pause_on_focus_loss()
	assert(is_instance_valid(scene.overlay))
	assert(Input.mouse_mode==Input.MOUSE_MODE_VISIBLE)
	var overlay: PanelContainer = scene.overlay
	scene.pause_on_focus_loss()
	assert(scene.overlay==overlay,"Duplicate pause on focus loss")
	var seconds: float = scene.session_seconds
	scene._physics_process(10)
	assert(scene.session_seconds==seconds,"Unfocused game timer advances")
	print("FOCUS PAUSE PASS: loses capture, opens one pause panel, stops patrol clock")
	quit()
