extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world=load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	world.photo_manifest="user://photo_test_manifest.json"
	world.photo_records.clear()
	world.observed_species.clear()
	world.player.set_physics_process(false)
	world.player.toggle_camera()
	for i in range(40):await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("C:/Users/zayatz/Downloads/lenskiy stolbi/camera_firstperson_preview.png")
	assert(world.player.camera_equipped)
	var mouse:=InputEventMouseButton.new()
	mouse.button_index=MOUSE_BUTTON_RIGHT;mouse.pressed=true
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	Input.parse_input_event(mouse)
	await create_timer(.7).timeout
	assert(world.player.camera_aim>.8 and world.player.camera.fov<float(world.player.settings.fov))
	assert(world.viewfinder.blend>.8 and not world.hud.visible)
	assert(not world.player.photo_camera.visible and not world.player.camera_support_hand.visible)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("C:/Users/zayatz/Downloads/lenskiy stolbi/camera_viewfinder_preview.png")
	await world.take_photo()
	assert(world.photo_records.size()==1)
	var aimed_image:=Image.new()
	assert(aimed_image.load(world.photo_records[0].path)==OK)
	# Border overlay must not be baked into the photo.
	var border_color:=aimed_image.get_pixel(10,10)
	assert(border_color.b>.15,"Viewfinder dark border leaked into photograph")
	world.pause_menu(false)
	await create_timer(.3).timeout
	assert(world.viewfinder.blend==0 and world.player.camera_aim<.01)
	world.overlay.free()
	world.resume()
	mouse.pressed=false;Input.parse_input_event(mouse)
	await create_timer(.5).timeout
	assert(world.player.camera_aim<.01)
	assert(world.hud.visible and world.player.photo_camera.visible)
	world.photo_records.clear()
	world.session_photos=0
	await world.take_photo()
	assert(world.photo_records.size()==1,"Photo count %d camera %s mouse %d busy %s" % [world.photo_records.size(),world.player.camera_equipped,Input.mouse_mode,world.photo_busy])
	assert(FileAccess.file_exists(world.photo_records[0].path))
	assert(not str(world.photo_records[0].taken).is_empty())
	assert(world.ui.visible and world.player.is_processing())
	assert(not world.player.is_physics_processing(),"Photo changed disabled physics state")
	assert(world.observed_species.is_empty())
	var saved_path: String=world.photo_records[0].path
	world.photo_records.clear()
	world.load_photo_records()
	assert(world.photo_records.size()==1 and world.photo_records[0].path==saved_path)
	world.load_photo_records()
	assert(world.photo_records.size()==1,"Repeated journal load duplicated records")
	await world.take_photo()
	assert(world.photo_records.size()==2 and world.photo_records[1].path!=saved_path)
	assert(world.session_photos==2)
	world.photo_records.pop_back()
	world.journal_menu()
	await process_frame
	var tasks=world.overlay.find_child("PatrolTasks",true,false)
	assert(tasks!=null and tasks.get_child_count()==3)
	var names=world.overlay.find_child("VerifiedPlantNames",true,false)
	if world.plant_catalog.entries.is_empty():assert(names!=null and names.get_child_count()==21)
	else:assert(world.plant_catalog.entries.size()==21)
	assert(world.observed_species.is_empty(),"Reference list granted observations")
	var galleries: Array=world.overlay.find_children("PhotoGallery","GridContainer",true,false)
	assert(galleries.size()==1 and galleries[0].get_child_count()==1)
	assert(not galleries[0].visible and tasks.visible)
	var journal_tabs=world.overlay.find_child("JournalTabs",true,false)
	journal_tabs.get_child(1).pressed.emit()
	assert(galleries[0].visible and not tasks.visible)
	journal_tabs.get_child(0).pressed.emit()
	assert(not galleries[0].visible and tasks.visible)
	journal_tabs.get_child(2).pressed.emit()
	var species_grid=world.overlay.find_child("SpeciesGrid",true,false)
	assert(species_grid.visible and species_grid.get_child_count()==21 and not tasks.visible)
	journal_tabs.get_child(0).pressed.emit()
	var preview:TextureRect=galleries[0].get_child(0).get_child(0).get_child(0)
	assert(preview.texture.get_width()<=600)
	journal_tabs.get_child(1).pressed.emit()
	var click:=InputEventMouseButton.new()
	click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true
	preview.gui_input.emit(click)
	await process_frame
	var viewer=world.overlay.find_child("PhotoLightbox",true,false)
	assert(viewer!=null and viewer.image_view.texture.get_width()>600)
	viewer.set_zoom(2)
	await create_timer(.25).timeout
	assert(is_equal_approx(viewer.zoom,2) and viewer.photo_area.clip_contents)
	viewer.pan=Vector2(9999,-9999)
	viewer.layout_photo()
	assert(viewer.pan.x<=580 and viewer.pan.y>=-290)
	viewer.set_zoom(1)
	await create_timer(.25).timeout
	assert(viewer.pan==Vector2.ZERO)
	viewer.queue_free()
	await process_frame
	await world.take_photo()
	assert(world.photo_records.size()==1,"Photo taken while menu open")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("C:/Users/zayatz/Downloads/lenskiy stolbi/photo_journal_preview.png")
	world.overlay.free()
	world.resume()
	world.player.dragging=true
	await create_timer(.1).timeout
	assert(not world.player.camera_equipped,"Camera remained equipped while towing")
	world.player.toggle_camera()
	assert(not world.player.camera_equipped)
	world.player.dragging=false
	world.pickup(world.rubbish[0])
	world.player.toggle_camera()
	assert(not world.player.camera_equipped)
	print("PHOTO PASS: camera equip, PNG saved, UI restored, unidentified scene grants no species, occupied hands rejected")
	quit()
