extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.player.set_physics_process(false)
	scene.player.position = Vector3(0,.2,-30)
	# Generic sphere is an explicit in-memory test fixture, not a rare species.
	scene.plant_catalog.entries.append({"id":"outline_fixture"})
	var body := StaticBody3D.new()
	body.collision_layer = 2
	body.collision_mask = 0
	body.position = Vector3(0,1.85,-32)
	body.set_meta("species_id","outline_fixture")
	var visual := MeshInstance3D.new()
	visual.mesh = SphereMesh.new()
	body.add_child(visual)
	body.set_meta("plant_visual",visual)
	var collider := CollisionShape3D.new()
	collider.shape = SphereShape3D.new()
	body.add_child(collider)
	scene.add_child(body)
	await physics_frame
	await physics_frame
	scene.update_focus()
	assert(scene.focused_species=="outline_fixture")
	assert(visual.material_overlay==scene.outline_material)
	assert(scene.focused_item==null)
	scene.player.camera.rotation.y = PI/2
	scene.update_focus()
	assert(scene.focused_species.is_empty() and visual.material_overlay==null)
	print("PLANT FOCUS PASS: camera ray recognizes test species, outlines only visual, clears on look away, never picks up")
	quit()
