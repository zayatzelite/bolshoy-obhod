extends SceneTree
var scene: Node3D
var ticks := 0
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Explicit UI fixture only: not a botanical record, never persisted or spawned.
	var fixture := {"id":"ui_fixture","name_ru":"ТЕСТ КАРТОЧКИ — НЕ ВИД РАСТЕНИЯ","name_latin":"UI layout fixture","description":"Проверка длинного описания. ".repeat(20),"habitat":"Тестовое поле, не научные сведения.","protection":"Проверка блока правил охраны.","source":"Только автоматический тест интерфейса.","photo":"res://assets/ui/heart.svg"}
	scene.plant_catalog.entries.append(fixture)
	scene.focused_species = "ui_fixture"
	scene.interact()
func _process(_delta: float) -> bool:
	if not is_instance_valid(scene):return false
	ticks+=1
	if ticks==3:
		assert(is_instance_valid(scene.overlay))
		assert(scene.observed_species.has("ui_fixture"))
		var rect: Rect2 = scene.overlay.get_global_rect()
		assert(rect.position.x>=0 and rect.position.y>=0 and rect.end.x<=1280 and rect.end.y<=720)
		scene.overlay.get_child(0).get_child(3).pressed.emit()
		assert(Input.mouse_mode==Input.MOUSE_MODE_CAPTURED)
		print("PLANT CARD PASS: bounded scroll layout, record interaction and close callback")
		quit()
	return false
