extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.position = Vector3(0,0.25,-35)
	scene.player.camera.rotation = Vector3(-0.08,0,0)
	for i in range(15):
		await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://../patrol_hud_preview.png")
	var panel = preload("res://scripts/game_settings.gd").make_panel(scene.ui,func() -> void: pass)
	for i in range(8):
		await process_frame
	await process_frame
	var rect: Rect2 = panel.get_global_rect()
	assert(rect.position.x>=0 and rect.position.y>=0)
	assert(rect.end.x<=1280 and rect.end.y<=720,"Settings outside viewport")
	root.get_texture().get_image().save_png("res://../patrol_settings_preview.png")
	panel.queue_free()
	await process_frame
	scene.pause_menu(true)
	for i in range(8):await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://../patrol_upgrades_preview.png")
	scene.overlay.queue_free()
	await process_frame
	scene.player.position = Vector3(-21,0.7,-90)
	for i in range(8):await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://../patrol_branch_preview.png")
	scene.player.position = scene.bases[0]+Vector3(0,.25,10)
	for i in range(8):await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://../patrol_base_preview.png")
	scene.player.position = scene.bases[0]+Vector3(0,.25,0)
	for i in range(8):await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://../patrol_interior_preview.png")
	for z in [0.0,-40.0,-95.0,-155.0]:
		var query := PhysicsRayQueryParameters3D.create(Vector3(0,10,z),Vector3(0,-4,z))
		var hit: Dictionary = scene.get_world_3d().direct_space_state.intersect_ray(query)
		assert(not hit.is_empty(),"Route ground missing at %s" % z)
	print("VISUAL PASS: HUD capture, settings within viewport, four route floor probes")
	quit()
