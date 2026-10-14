extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await process_frame
	scene.player._process(0)
	assert(not scene.player.carrying_hand.visible)
	scene.pickup(scene.rubbish[0])
	scene.player._process(0)
	assert(scene.player.carrying_hand.visible)
	var meshes = scene.player.carrying_hand.find_children("*","MeshInstance3D",true,false)
	assert(meshes.size()==1)
	var mesh: MeshInstance3D = meshes[0]
	assert(mesh.mesh.get_surface_count()==4)
	var bounds: AABB = mesh.transform*mesh.mesh.get_aabb()
	assert(bounds.size.y>.4 and bounds.size.y<.6)
	assert(mesh.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	scene.inventory_menu()
	scene.player._process(0)
	assert(not scene.player.carrying_hand.visible)
	scene.overlay.free()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	scene.player._process(0)
	assert(scene.player.carrying_hand.visible)
	scene.stow_or_retrieve()
	scene.player._process(0)
	assert(not scene.player.carrying_hand.visible)
	print("HAND VISIBILITY PASS: one Blender mesh, four materials, expected scale, no shadows, held/pause/stowed visibility correct")
	quit()
