extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	# Synthetic interface fixture only. It is never persisted or placed in the world.
	scene.plant_catalog.entries.assign([{"id":"test_only","name_ru":"Тестовая запись интерфейса","name_latin":"Test fixture","description":"Проверка окна","habitat":"Не является видом","protection":"Только тест","source":"In-memory test","photo":"res://assets/menu/background.png"}])
	scene.observed_species["test_only"] = true
	scene.journal_menu()
	var records = scene.overlay.get_child(0).get_child(2).get_child(0)
	records.get_child(1).pressed.emit()
	for tick in range(5):await process_frame
	assert(scene.overlay.size==Vector2(1280,720))
	assert(scene.overlay.get_child(0).get_child(0).text=="Тестовая запись интерфейса")
	scene.overlay.get_child(0).get_child(3).pressed.emit()
	assert(scene.overlay.get_child(0).get_child(0).text=="ЖУРНАЛ ОБХОДА")
	print("HERBARIUM REOPEN PASS: observed record opens fullscreen card and returns to journal; synthetic fixture memory-only")
	quit()
