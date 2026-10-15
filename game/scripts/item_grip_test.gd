extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world=load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	world.player.set_physics_process(false)
	world.player.set_process_unhandled_input(false)
	world.player.rotation=Vector3.ZERO
	world.player.camera.rotation=Vector3.ZERO
	var items:Array=world.rubbish.slice(0,3)
	for i in range(3):
		if is_instance_valid(world.held_item):world.drop_held()
		world.pickup(items[i])
		await create_timer(.4).timeout
		assert(world.held_item.get_parent()==world.player.carry_rig)
		assert(world.player.grip_variants[world.player.active_grip].visible)
		assert(not world.player.carrying_hand.visible)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("C:/Users/zayatz/Downloads/lenskiy stolbi/item_grip_%d.png" % i)
		world.player.set_process(false)
		var detail_camera:=Camera3D.new()
		world.add_child(detail_camera)
		detail_camera.global_transform=world.player.camera.global_transform
		detail_camera.fov=45
		detail_camera.cull_mask=world.player.camera.cull_mask
		detail_camera.look_at(world.player.camera.to_global(Vector3(.30,-.40,-.75)),Vector3.UP)
		detail_camera.current=true
		world.ui.hide()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("C:/Users/zayatz/Downloads/lenskiy stolbi/item_grip_detail_%d.png" % i)
		detail_camera.free()
		world.player.camera.current=true
		world.ui.show()
		world.player.set_process(true)
	print("GRIP CAPTURE PASS: three item types attached to animated carry rig, hand visible")
	quit()
