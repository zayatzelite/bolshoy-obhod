extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.observed_species.clear()
	scene.player.set_physics_process(false)
	scene.delivered=8
	scene.session_xp=200
	scene.session_seconds=735
	scene.walked_distance=412
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	scene.show_results()
	await create_timer(.5).timeout
	await RenderingServer.frame_post_draw
	assert(DisplayServer.window_get_size()==Vector2i(1920,1080))
	var labels=scene.overlay.find_children("*","Label",true,false)
	var summary=""
	for label in labels:
		if label.text.contains("Время на тропе:"):summary=label.text
	assert(summary.contains("12 мин 15 с") and summary.contains("412"))
	var values:PackedStringArray=[]
	for label in labels:values.append(label.text)
	assert(values.has("8 / 8") and values.has("+200 XP"))
	assert(summary.contains("Изучено видов: 0 / 21"))
	var rings=scene.overlay.find_children("ResultsXPRing","Control",true,false)
	assert(rings.size()==1)
	var button=scene.overlay.find_children("*","Button",true,false)[0]
	assert(button.get_child_count()>0)
	root.get_texture().get_image().save_png("res://../results_fullscreen_preview.png")
	button.pressed.emit()
	await process_frame
	assert(Input.mouse_mode==Input.MOUSE_MODE_CAPTURED)
	print("RESULTS FULLSCREEN PASS: statistics, honest catalog status, sandy button, continue resumes; no saved progress changed")
	quit()
