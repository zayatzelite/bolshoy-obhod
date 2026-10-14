extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.progression = preload("res://scripts/test_memory_progress.gd").new()
	scene.progression.xp = 0
	scene.progression.spent = 0
	scene.progression.ranks = {"stamina":0,"cart":0,"boots":0}
	var panel = preload("res://scripts/game_settings.gd").make_panel(scene.ui,func() -> void: pass)
	assert(is_instance_valid(panel))
	panel.queue_free()
	for item in scene.rubbish.duplicate():
		scene.player.position = item.position
		scene.cart.position = item.position+Vector3(1,0,0)
		scene.pickup(item)
		assert(scene.held_item==item)
		scene.stow_or_retrieve()
		assert(scene.inventory.size()==1 and scene.held_item==null)
		scene.stow_or_retrieve()
		assert(scene.inventory.is_empty() and scene.held_item==item)
		scene.interact()
		await process_frame
		if scene.cargo==4:
			scene.player.position = scene.delivery_points[0]
			var old_delivered: int = scene.delivered
			scene.interact()
			assert(scene.delivered==old_delivered,"Delivered without cart")
			scene.cart.position = scene.delivery_points[0]+Vector3(1,.3,0)
			scene.interact()
	assert(scene.delivered==8, "Delivery cycle failed")
	assert(scene.cargo==0)
	assert(scene.progression.xp==200)
	assert(scene.progression.upgrade("cart"))
	assert(scene.progression.capacity()==6)
	assert(scene.progression.points()==1)
	assert(not scene.progression.upgrade("unknown"))
	assert(scene.progression.saves>0) # Test-memory backend only; never writes user://.
	scene.pause_menu(true)
	assert(is_instance_valid(scene.overlay))
	print("SMOKE PASS: settings panel, eight pickups, two deliveries, pause")
	quit()
