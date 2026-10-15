extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world=load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	world.delivered=3
	world.journal_menu()
	await create_timer(.4).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../journal_tasks_preview.png")
	var tabs=world.overlay.find_child("JournalTabs",true,false)
	tabs.get_child(2).pressed.emit()
	await create_timer(.3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../journal_species_preview.png")
	var grid=world.overlay.find_child("SpeciesGrid",true,false)
	assert(grid.get_child_count()==21)
	for card in grid.get_children():
		assert(card.size.x>=256 and card.size.y>=200)
		var bounds:Rect2=card.get_global_rect()
		assert(bounds.end.x<=626 or bounds.position.x>=654,"Species card overlaps journal spine")
		for child in card.get_children():
			if child is Label:assert(child.position.y+child.size.y<=card.size.y)
	print("JOURNAL VISUAL PASS: task progress and 21 species cards captured; captions bounded")
	quit()
