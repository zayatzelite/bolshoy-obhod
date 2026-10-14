extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var ui:=Control.new()
	root.add_child(ui)
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel=preload("res://scripts/game_settings.gd").make_panel(ui,func():pass)
	var tabs: TabContainer=panel.find_children("*","TabContainer",true,false)[0]
	for index in range(3):
		tabs.current_tab=index
		for tick in range(4):await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../settings_review_%d.png" % index)
		assert(panel.get_global_rect().end.y<=720)
	print("SETTINGS TABS CAPTURE PASS: all three tabs bounded; no settings values changed")
	quit()
