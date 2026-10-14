extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	var birds: Node3D
	var clouds: Node3D
	for child in scene.get_children():
		if child.get_script()==preload("res://scripts/sky_birds.gd"):birds = child
		if child.get_script()==preload("res://scripts/soft_clouds.gd"):clouds = child
	assert(birds!=null and clouds!=null)
	scene.map_menu()
	var bird_time: float = birds.elapsed
	var cloud_time: float = clouds.time
	birds._process(10)
	clouds._process(10)
	scene.update_effect_time(10)
	assert(scene.effect_time==0)
	assert(scene.animated_materials.size()==3)
	assert(birds.elapsed==bird_time and clouds.time==cloud_time)
	scene.overlay.queue_free()
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	birds._process(1)
	clouds._process(1)
	scene.update_effect_time(1)
	assert(scene.effect_time>0)
	for material in scene.animated_materials:assert(material.get_shader_parameter("patrol_time")==scene.effect_time)
	assert(birds.elapsed>bird_time and clouds.time>cloud_time)
	print("SKY PAUSE PASS: map freezes bird/cloud animation; capture resumes it")
	quit()
