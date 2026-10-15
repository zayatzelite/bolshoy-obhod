extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var ring=preload("res://scripts/results_xp_ring.gd").new()
	ring.xp=325;ring.earned=250
	root.add_child(ring)
	assert(ring.level==1 and is_equal_approx(ring.fill,.75))
	ring.update_display(100)
	assert(ring.level==2 and ring.fill==0)
	ring.update_display(299)
	assert(ring.level==3 and is_equal_approx(ring.fill,.99))
	await create_timer(2.2).timeout
	assert(ring.level==4 and is_equal_approx(ring.fill,.25))
	print("XP RING PASS: 75 to 325 XP, boundary resets, level 1 to 4, final quarter ring")
	quit()
