extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await physics_frame
	await physics_frame
	scene.player.health = 40
	scene.player.stamina = 1
	scene.player.position = Vector3(0,.2,-40)
	assert(not scene.rest_at_base())
	assert(scene.player.health==40)
	var xp: int = scene.progression.xp
	scene.pickup(scene.rubbish[0])
	scene.stow_or_retrieve()
	var stored: Node3D = scene.inventory[0]
	scene.pickup(scene.rubbish[0])
	var held: Node3D = scene.held_item
	scene.cargo = 2
	for at in scene.bases:
		scene.player.position = at+Vector3(-2,.2,-1.5)
		scene.player.health = 40
		scene.player.stamina = 1
		scene.pause_menu(true)
		var actions = scene.overlay.get_child(0).get_child(1)
		var rest: Button = actions.get_child(1)
		assert(rest.text=="Отдых" and not rest.disabled)
		rest.pressed.emit()
		assert(scene.player.health==100 and scene.player.stamina==100)
		await process_frame
		scene.pause_menu(true)
		assert(scene.overlay.get_child(0).get_child(1).get_child(1).disabled)
		for tick in range(3):await process_frame
		assert(scene.overlay.get_global_rect().end.y<=720,"Rest button overflows")
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../patrol_station_menu.png")
		scene.overlay.free()
	assert(scene.progression.xp==xp and scene.cargo==2)
	assert(scene.held_item==held and scene.inventory.size()==1 and scene.inventory[0]==stored)
	print("BASE REST PASS: trail denied, both interiors restore vitals, journal bounded, progress unchanged")
	quit()
