extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.player.set_physics_process(false)
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	scene.progression=preload("res://scripts/test_memory_progress.gd").new()
	scene.progression.xp=0
	scene.progression.ranks={"stamina":0,"cart":0,"boots":0}
	var tree=preload("res://scripts/skill_tree.gd").new()
	tree.world=scene
	scene.ui.add_child(tree)
	scene.player.position=Vector3(0,.2,-40)
	tree.refresh()
	assert(tree.nodes[0].text.contains("Нет очков навыков"))
	assert(tree.nodes[1].text.contains("Нужен уровень 1"))
	scene.progression.xp=200
	tree.refresh()
	assert(tree.nodes[0].text.contains("Покупка на базе"))
	tree.purchase("stamina",1)
	assert(scene.progression.ranks.stamina==0)
	scene.player.position=scene.bases[0]+Vector3(-2,.2,-1.5)
	await physics_frame
	await physics_frame
	assert(scene.at_upgrade_station())
	tree.refresh()
	assert(not tree.nodes[0].disabled and tree.nodes[0].text.contains("Изучить"))
	tree.purchase("stamina",1)
	assert(scene.progression.ranks.stamina==1)
	assert(tree.nodes[0].text.contains("ИЗУЧЕНО") and tree.nodes[0].disabled)
	assert(tree.nodes[0].get_theme_color("font_disabled_color")==Color("30271c"))
	assert(tree.nodes[0].get_meta("button_material").get_shader_parameter("selected"))
	assert(not tree.nodes[1].get_meta("button_material").get_shader_parameter("selected"))
	assert(not tree.nodes[1].disabled)
	assert(scene.progression.saves==1)
	print("SKILL STATUS PASS: zero points, prerequisite, away/base, purchase and learned contrast; saves in memory only")
	quit()
