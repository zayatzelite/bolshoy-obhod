extends SceneTree
var scene: Node3D
var ticks := 0
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.prompt.text = "E у тележки — загрузить\nR — убрать · G — положить"
	scene.notify("Не удалось сохранить опыт. Груз сохранён в тележке — попробуйте снова.")
func _process(_delta: float) -> bool:
	if not is_instance_valid(scene):return false
	ticks+=1
	if ticks==8:
		for label in [scene.prompt,scene.message]:
			var rect: Rect2 = label.get_parent().get_parent().get_global_rect()
			print("HUD RECT: ",rect)
			if rect.position.x<0 or rect.position.y<0 or rect.end.x>1280 or rect.end.y>720:
				push_error("Active HUD panel outside viewport");quit(1);return true
		root.get_texture().get_image().save_png("res://../patrol_hud_bounds_preview.png")
		print("HUD BOUNDS PASS: multiline hand hint and long notice inside viewport")
		quit();return true
	return false
