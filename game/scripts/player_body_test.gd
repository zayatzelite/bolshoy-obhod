extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world=load("res://scenes/world.tscn").instantiate()
	root.add_child(world)
	world.player.set_physics_process(false)
	for test in [[Vector3.ZERO,"Idle"],[Vector3(4,0,0),"Walk"],[Vector3(0,0,-7),"Run"]]:
		world.player.velocity=test[0]
		world.player.update_body_animation()
		assert(world.player.body_animator.current_animation==test[1])
		assert(world.player.body_animator.get_animation(test[1]).loop_mode==Animation.LOOP_LINEAR)
	assert(world.player.character_body.visible)
	assert(world.player.character_body.find_child("Boot L",true,false).visible)
	assert(world.player.character_body.find_child("Head",true,false).layers==2 and world.player.camera.cull_mask & 2==0)
	world.player.velocity=Vector3.ZERO
	world.player.update_body_animation()
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	world.player.update_body_animation()
	assert(not world.player.body_animator.is_playing())
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	world.player.update_body_animation()
	assert(world.player.body_animator.is_playing())
	world.player.camera.rotation.x=-1.3
	await create_timer(.3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("C:/Users/zayatz/Downloads/lenskiy stolbi/player_legs_preview.png")
	print("PLAYER BODY PASS: movement selects Idle Walk Run; FPS camera not obstructed")
	quit()
