extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world=load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	world.progression=preload("res://scripts/test_memory_progress.gd").new()
	world.progression.xp=475
	world.experience=475
	world.player.set_physics_process(false)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	await create_timer(.4).timeout
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	await create_timer(.2).timeout
	var ring:Control=world.hud.level_ring
	assert(ring.xp==475 and is_equal_approx(ring.shown,475))
	assert(ring.get_global_rect().end.x<=1280 and ring.get_global_rect().position.x>1100)
	assert(not world.hud.xp_label.get_parent().get_parent().visible)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("C:/Users/zayatz/Downloads/lenskiy stolbi/hud_level_fullscreen.png")
	world.player.toggle_camera()
	var mouse:=InputEventMouseButton.new()
	mouse.button_index=MOUSE_BUTTON_RIGHT;mouse.pressed=true
	Input.parse_input_event(mouse)
	await create_timer(.7).timeout
	assert(world.viewfinder.blend>.95 and not world.hud.visible)
	assert(world.viewfinder.size.is_equal_approx(Vector2(1280,720)))
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("C:/Users/zayatz/Downloads/lenskiy stolbi/camera_fullscreen_preview.png")
	mouse.pressed=false;Input.parse_input_event(mouse)
	await create_timer(.4).timeout
	assert(world.hud.visible and world.viewfinder.blend<.01)
	print("CAMERA FULLSCREEN PASS: corner level 5 / 75 XP, central strip hidden, scaled glass viewfinder, HUD restored, memory progress only")
	quit()
