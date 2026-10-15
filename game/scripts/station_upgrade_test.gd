extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	scene.progression=preload("res://scripts/test_memory_progress.gd").new()
	scene.progression.xp=600
	scene.progression.spent=3
	scene.progression.ranks={"stamina":3,"cart":0,"boots":0}
	var tree=preload("res://scripts/skill_tree.gd").new()
	tree.world=scene
	scene.ui.add_child(tree)
	scene.player.position=Vector3(0,.2,-40)
	tree.refresh()
	tree.purchase("cart",1)
	assert(scene.progression.ranks.cart==0 and scene.progression.saves==0)
	scene.player.position=scene.bases[1]+Vector3(-2,.2,-1.5)
	await physics_frame
	await physics_frame
	assert(scene.at_upgrade_station())
	tree.refresh()
	tree.purchase("cart",1)
	assert(scene.progression.capacity()==6 and scene.progression.points()==2)
	assert(scene.progression.saves==1)
	tree.purchase("stamina",3)
	assert(scene.progression.ranks.stamina==3 and scene.progression.saves==1)
	print("STATION UPGRADE PASS: trail rejected, far-base cart purchased, learned rank rejected; memory saves only")
	quit()
