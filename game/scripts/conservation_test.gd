extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world=load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	world.observed_species.clear()
	# Synthetic fixture only: never installed in the playable catalog.
	world.plant_catalog.entries.assign([{"id":"test-protected","name":"Test fixture"}])
	var plant:=Node3D.new();world.add_child(plant);plant.set_meta("species_id","test-protected")
	var xp:int=world.progression.xp
	world.pickup(plant)
	assert(world.conservation_warnings==1 and world.conservation_penalty==0)
	assert(world.held_item==null and plant.get_parent()==world)
	world.pickup(plant)
	assert(world.conservation_violations==1 and world.conservation_penalty==25)
	assert(world.progression.xp==xp and world.observed_species.is_empty())
	var unknown:=Node3D.new();world.add_child(unknown);unknown.set_meta("species_id","not-confirmed")
	assert(not world.protect_plant(unknown))
	print("CONSERVATION PASS: warning then rating penalty, plant preserved, no XP loss or false discovery")
	quit()
