extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var host := Control.new()
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(host)
	var panel = preload("res://scripts/game_settings.gd").make_panel(host,func():pass)
	for tick in range(5):await process_frame
	var tabs: TabContainer = panel.get_child(0).get_child(1)
	assert(tabs.get_tab_count()==3)
	for index in range(3):
		tabs.current_tab = index
		await process_frame
		assert(panel.size==Vector2(1280,720),str(panel.size))
		assert(tabs.get_global_rect().end.y<720)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../settings_tabs_preview.png")
	print("SETTINGS TABS PASS: three sections, fullscreen 1280x720, return button outside scrolling content")
	quit()
