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
	for variant in scene.player.grip_variants.values():assert(not variant.visible)
	scene.pickup(scene.rubbish[0])
	scene.player._process(0)
	assert(scene.player.grip_variants[scene.player.active_grip].visible)
	var meshes = scene.player.grip_variants[scene.player.active_grip].find_children("*","MeshInstance3D",true,false)
	assert(meshes.size()>=1)
	for mesh:MeshInstance3D in meshes:
		assert(mesh.mesh!=null)
		assert(mesh.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	scene.inventory_menu()
	scene.player._process(0)
	assert(not scene.player.carrying_hand.visible)
	for variant in scene.player.grip_variants.values():assert(not variant.visible)
	scene.overlay.free()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	scene.player._process(0)
	assert(scene.player.grip_variants[scene.player.active_grip].visible)
	scene.stow_or_retrieve()
	scene.player._process(0)
	assert(not scene.player.carrying_hand.visible)
	for variant in scene.player.grip_variants.values():assert(not variant.visible)
	print("HAND VISIBILITY PASS: per-item glove meshes, no first-person shadows, held/pause/stowed visibility correct")
	quit()
