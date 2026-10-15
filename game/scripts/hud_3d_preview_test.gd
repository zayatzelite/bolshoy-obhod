extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.progression=preload("res://scripts/test_memory_progress.gd").new()
	scene.player.set_physics_process(false)
	await process_frame
	scene.pickup(scene.rubbish[0])
	for i in range(8):await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("C:/Users/zayatz/Downloads/lenskiy stolbi/hud_3d_preview.png")
	assert(scene.hud.hotbar_icons[0] is SubViewportContainer)
	assert(scene.hud.cargo_label.text.contains("ТЕЛЕЖКА"))
	print("3D HUD PASS: mesh preview and cart label; screenshot saved")
	quit()
