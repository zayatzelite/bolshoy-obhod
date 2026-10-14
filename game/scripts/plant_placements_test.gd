extends SceneTree
func _initialize() -> void:
	var catalog = preload("res://scripts/plant_catalog.gd").new()
	catalog.entries.append({"id":"ui_fixture"})
	var loader = preload("res://scripts/plant_placements.gd").new()
	var point := {"species_id":"ui_fixture","position":[0,0,-20],"source":"TEST ONLY"}
	assert(loader.validate({"placements":[point]},catalog).size()==1)
	point.position = [500,0,-20]
	assert(loader.validate({"placements":[point]},catalog).is_empty())
	point.position = [0,0,-20]
	point.species_id = "unknown"
	assert(loader.validate({"placements":[point]},catalog).is_empty())
	point.species_id = "ui_fixture"
	point.source = ""
	assert(loader.validate({"placements":[point]},catalog).is_empty())
	var temporary_parent := Node3D.new()
	assert(loader.spawn(temporary_parent,catalog,"res://data/absent.json")==0)
	temporary_parent.free()
	print("PLACEMENTS PASS: valid point accepted, unknown species, outside map and missing source rejected; absent dataset spawns nothing")
	quit()
