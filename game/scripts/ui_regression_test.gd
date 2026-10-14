extends SceneTree
var scene: Node3D
var ticks := 0
var phase := 0
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.message_timer = 0
	scene.prompt.text = ""
	scene.pause_menu(true)
func _process(_delta: float) -> bool:
	if not is_instance_valid(scene):return false
	ticks+=1
	if ticks%8!=0:return false
	var rect: Rect2 = scene.overlay.get_global_rect()
	if rect.position.x<0 or rect.position.y<0 or rect.end.x>1280 or rect.end.y>720:
		push_error("UI outside viewport, phase %d: %s" % [phase,rect]);quit(1);return true
	assert(not scene.hud.prompt_label.get_parent().get_parent().visible)
	assert(not scene.hud.notice_label.get_parent().get_parent().visible)
	root.get_texture().get_image().save_png("res://../patrol_ui_review_%d.png" % phase)
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE;escape.pressed = true
	scene._unhandled_input(escape)
	assert(Input.mouse_mode==Input.MOUSE_MODE_CAPTURED)
	scene.overlay.free()
	phase+=1
	if phase==1:
		scene.pause_menu(false)
	elif phase==2:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		scene.overlay = preload("res://scripts/game_settings.gd").make_panel(scene.ui,scene.resume)
	elif phase==3:
		scene.map_menu()
	elif phase==4:
		scene.inventory_menu()
	elif phase==5:
		scene.journal_menu()
	else:
		print("UI REGRESSION PASS: skills, pause, settings, map, inventory, journal bounded; empty hints hidden; Escape resumes")
		quit();return true
	return false
