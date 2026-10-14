extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	var labels: Array[String]=[]
	for node in scene.find_children("*","Label3D",true,false):labels.append(node.text)
	assert(labels.has("→  БЕРЕГ · ОБЗОР СТОЛБОВ"))
	assert(labels.has("↑  БАЗА · СДАЧА МУСОРА"))
	assert(labels.has("←  ЛЕСНАЯ ПРОГУЛОЧНАЯ ПЕТЛЯ"))
	assert(not labels.has("←  ПРОХОД СРЕДИ СТОЛБОВ"))
	scene.player.set_physics_process(false)
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	scene.message_timer=0
	scene.player.position=Vector3(24,.1,-134)
	scene.player.camera.look_at(Vector3(24,1.5,-138))
	for tick in range(5):await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../riverside_sign_preview.png")
	print("ROUTE SIGNS PASS: labels reflect updated routes; riverside sign capture saved")
	quit()
