extends SceneTree
func _initialize() -> void:
	var catalog = preload("res://scripts/plant_catalog.gd").new()
	assert(not catalog.load_catalog())
	assert(catalog.entries.is_empty())
	assert(not catalog.validate({"species":[]},false))
	var records: Array = []
	for i in range(22):
		records.append({"id":"test_%d" % i,"name_ru":"TEST ONLY","name_latin":"TEST ONLY","description":"test","habitat":"test","protection":"test","source":"test fixture","photo":"res://test.png","model":"res://test.glb"})
	assert(catalog.validate({"species":records},false))
	assert(catalog.find_species("test_21").id=="test_21")
	records[1].id = records[0].id
	assert(not catalog.validate({"species":records},false))
	assert(catalog.entries.is_empty())
	records[1].id = "test_1"
	records[0].erase("protection")
	assert(not catalog.validate({"species":records},false))
	records[0].protection = "test"
	for record in records:
		record.photo = "res://assets/ui/heart.svg"
		record.model = "res://assets/litter_bottle.glb"
	assert(catalog.validate({"species":records},true),str(catalog.errors))
	records[0].photo = "res://scripts/player.gd"
	assert(not catalog.validate({"species":records},true))
	records[0].photo = "res://assets/ui/heart.svg"
	records[0].model = "res://scenes/bootstrap.tscn"
	assert(not catalog.validate({"species":records},true))
	print("CATALOG PASS: missing database, count, duplicate IDs, mandatory fields, resource types and 3D root; test fixtures never saved")
	quit()
