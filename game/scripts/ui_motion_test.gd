extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world=load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	world.journal_menu()
	await process_frame
	await process_frame
	assert(world.overlay.has_meta("motion_revealed"))
	assert(world.overlay.modulate.a<1)
	await create_timer(.35).timeout
	assert(is_equal_approx(world.overlay.modulate.a,1))
	var button:Button=world.overlay.find_children("*","Button",true,false)[0]
	button.mouse_entered.emit()
	await create_timer(.2).timeout
	var background:ColorRect=button.get_children().filter(func(child):return child is ColorRect)[0]
	assert(is_equal_approx(background.material.get_shader_parameter("hover"),1))
	var tabs=world.overlay.find_child("JournalTabs",true,false)
	var records=world.overlay.find_child("JournalRecords",true,false)
	for index in [1,2,0,1,2]:
		tabs.get_child(index).pressed.emit()
		assert(records.modulate.a<1)
	await create_timer(.3).timeout
	assert(is_equal_approx(records.modulate.a,1))
	assert(world.overlay.find_child("SpeciesGrid",true,false).visible)
	assert(world.hud.compass.position.y==5)
	print("UI MOTION PASS: panel fades in, hover interpolates, compass at top")
	quit()
