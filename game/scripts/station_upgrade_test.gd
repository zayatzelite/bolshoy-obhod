extends SceneTree
func _initialize() -> void:call_deferred("run")
func find_upgrade(scene: Node3D, key: String) -> Button:
	for child in scene.overlay.get_child(0).get_children():
		if child is Button and child.get_meta("upgrade_key","")==key:return child
	return null
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var old_xp: int = scene.progression.xp
	var old_spent: int = scene.progression.spent
	var old_ranks: Dictionary = scene.progression.ranks.duplicate()
	scene.progression.xp = 600
	scene.progression.spent = 3
	scene.progression.ranks = {"stamina":3,"cart":0,"boots":0}
	scene.player.position = Vector3(0,.2,-40)
	scene.pause_menu(true)
	var cart_button := find_upgrade(scene,"cart")
	assert(cart_button.disabled,"Trail upgrade enabled")
	cart_button.pressed.emit()
	assert(scene.progression.ranks.cart==0,"Trail purchase bypassed station")
	scene.overlay.free()
	scene.player.position = scene.bases[1]+Vector3(-2,.2,-1.5)
	scene.pause_menu(true)
	cart_button = find_upgrade(scene,"cart")
	assert(not cart_button.disabled)
	cart_button.pressed.emit()
	assert(scene.progression.capacity()==6 and scene.progression.points()==2)
	assert(find_upgrade(scene,"stamina").disabled,"Max rank reenabled")
	var reloaded = preload("res://scripts/progression.gd").new()
	reloaded.load_progress()
	assert(reloaded.capacity()==6 and reloaded.points()==2)
	scene.progression.xp = old_xp
	scene.progression.spent = old_spent
	scene.progression.ranks = old_ranks
	assert(scene.progression.save_progress()==OK)
	print("STATION UPGRADE PASS: trail rejected, station purchase saved, maximum rank stays disabled; prior save restored")
	quit()
