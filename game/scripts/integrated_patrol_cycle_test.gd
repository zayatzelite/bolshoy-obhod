extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world=load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	for sample in [[0,"0 снимков"],[1,"1 снимок"],[2,"2 снимка"],[11,"11 снимков"],[21,"21 снимок"],[24,"24 снимка"]]:
		assert(world.photo_count_text(sample[0])==sample[1])
	world.player.set_physics_process(false)
	world.player.set_process_unhandled_input(false)
	world.set_physics_process(false)
	world.progression=preload("res://scripts/test_memory_progress.gd").new()
	world.photo_manifest="user://integrated_patrol_cycle_manifest.json"
	world.photo_records.clear()
	world.observed_species.clear()
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	world.player.toggle_camera()
	await create_timer(.4).timeout
	await world.take_photo()
	assert(world.session_photos==1 and world.photo_records.size()==1)
	assert(world.observed_species.is_empty(),"Untargeted photo must not award a species")
	world.journal_menu()
	await process_frame
	var gallery=world.overlay.find_child("PhotoGallery",true,false)
	assert(gallery!=null and gallery.get_child_count()==1)
	world.overlay.free()
	world.resume()
	world.player.camera_equipped=false
	world.player.position=Vector3(0,.2,-20)
	world.cart.position=Vector3(0,.2,-22)
	world.pickup(world.rubbish[0])
	await process_frame
	assert(not world.player.active_grip.is_empty())
	world.stow_or_retrieve()
	assert(world.held_item==null and world.inventory.size()==1)
	world.select_hotbar(0)
	assert(world.held_item!=null and world.inventory.is_empty())
	world.interact()
	assert(world.cargo==1)
	for batch in range(2):
		world.player.position=Vector3(0,.2,-20)
		world.cart.position=Vector3(0,.2,-22)
		while world.cargo<4:
			world.pickup(world.rubbish[0])
			world.interact()
		world.player.position=world.delivery_points[batch]+Vector3(0,.2,1.5)
		world.cart.position=world.delivery_points[batch]+Vector3(0,.2,0)
		world.interact()
		await process_frame
		assert(world.cargo==0 and world.delivered==(batch+1)*4)
		if batch==0:assert(not world.results_shown)
	assert(world.results_shown and is_instance_valid(world.overlay))
	assert(world.session_photos==1 and world.session_xp==200 and world.progression.xp==200)
	assert(world.rubbish.is_empty() and world.inventory.is_empty())
	await create_timer(.45).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../integrated_patrol_results.png")
	print("INTEGRATED PATROL PASS: one session photo/journal/stow/retrieve/8 pickups/two deliveries/200 XP/results. In-memory progression; isolated photo manifest. Positions staged, NOT manual traversal.")
	quit()
