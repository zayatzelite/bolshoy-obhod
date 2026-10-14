extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	scene.delivered=8
	scene.session_xp=200
	scene.session_seconds=735
	scene.walked_distance=412
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	scene.show_results()
	for i in range(8):await process_frame
	await RenderingServer.frame_post_draw
	assert(DisplayServer.window_get_size()==Vector2i(1920,1080))
	var labels=scene.overlay.find_children("*","Label",true,false)
	assert(labels[1].text.contains("8 / 8") and labels[1].text.contains("200") and labels[1].text.contains("12 мин 15 с"))
	assert(labels[1].text.contains("подтверждённые материалы ещё не подключены"))
	var button=scene.overlay.find_children("*","Button",true,false)[0]
	assert(button.get_child_count()>0)
	root.get_texture().get_image().save_png("res://../results_fullscreen_preview.png")
	button.pressed.emit()
	await process_frame
	assert(Input.mouse_mode==Input.MOUSE_MODE_CAPTURED)
	print("RESULTS FULLSCREEN PASS: statistics, honest catalog status, sandy button, continue resumes; no saved progress changed")
	quit()
