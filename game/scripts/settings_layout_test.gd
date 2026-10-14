extends SceneTree
var panel: PanelContainer
var ticks := 0
func _initialize() -> void:
	call_deferred("setup")
func setup() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	panel = preload("res://scripts/game_settings.gd").make_panel(scene.ui,func() -> void:pass)
func _process(_delta: float) -> bool:
	if not is_instance_valid(panel):return false
	ticks+=1
	if ticks==20:
		var rect := panel.get_global_rect()
		print("SETTINGS RECT: ",rect)
		if rect.position.x<0 or rect.position.y<0 or rect.end.x>1280 or rect.end.y>720:
			push_error("Settings outside viewport")
			quit(1)
			return true
		var close: Button = panel.get_child(0).get_child(1)
		var close_rect := close.get_global_rect()
		assert(close_rect.end.y<=rect.end.y and close_rect.position.y>=rect.position.y,"Return button inaccessible")
		root.get_texture().get_image().save_png("res://../patrol_settings_preview.png")
		print("SETTINGS PASS: centered bounded scroll panel")
		quit()
	return false
