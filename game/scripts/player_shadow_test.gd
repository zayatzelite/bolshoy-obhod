extends SceneTree

# CPU triangle silhouette test is valid headless; optional -- --capture needs GPU.
const PLAYER = preload("res://scripts/player.gd")
const RESOLUTION := 200
const MINIMUM := Vector2(-2,-2)
const EXTENT := 4.0

func _initialize() -> void: call_deferred("run")

func silhouette(body: Node3D, mask: int, include_proxies: bool) -> Dictionary:
	var pixels := {}
	var light_basis := Basis.from_euler(Vector3(deg_to_rad(-45),deg_to_rad(-30),0))
	var ray := -light_basis.z
	for mesh: MeshInstance3D in body.find_children("*", "MeshInstance3D", true, false):
		if mesh.name.ends_with("ShadowProxy") and not include_proxies: continue
		if not mesh.visible or not (mesh.layers & mask) or mesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF: continue
		for surface in range(mesh.mesh.get_surface_count()):
			var arrays := mesh.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			var projected: Array[Vector2] = []
			for local in vertices:
				var point := mesh.global_transform * local
				point -= ray * (point.y/ray.y)
				projected.append((Vector2(point.x,point.z)-MINIMUM)/EXTENT*RESOLUTION)
			for triangle in range(0,indices.size(),3):
				var a := projected[indices[triangle]]
				var b := projected[indices[triangle+1]]
				var c := projected[indices[triangle+2]]
				var low := a.min(b).min(c).floor().max(Vector2.ZERO)
				var high := a.max(b).max(c).ceil().min(Vector2.ONE*(RESOLUTION-1))
				for y in range(int(low.y),int(high.y)+1):
					for x in range(int(low.x),int(high.x)+1):
						if Geometry2D.point_is_inside_triangle(Vector2(x+.5,y+.5),a,b,c): pixels[Vector2i(x,y)] = true
	return pixels

func run() -> void:
	var scene := Node3D.new()
	root.add_child(scene)
	var player := CharacterBody3D.new()
	scene.add_child(player)
	player.set_script(PLAYER)
	player.set_process(false)
	player.set_physics_process(false)
	var camera := Camera3D.new()
	player.add_child(camera)
	player.camera = camera
	var body: Node3D = load(PLAYER.CHARACTER_BODY_PATH).instantiate()
	player.add_child(body)
	player.character_body = body
	body.position.z = .12
	var animators := body.find_children("*", "AnimationPlayer", true, false)
	assert(not animators.is_empty())
	for animation_name in ["Idle", "Walk", "Run"]:
		assert(animators[0].has_animation(animation_name), "Refined asset lost required body animation")
	player.configure_body_visibility()
	assert(player.body_shadow_proxies.size() > 0)
	var head: MeshInstance3D = body.find_child("Head",true,false)
	assert(head != null and head.layers == 2 and camera.cull_mask & 2 == 0)
	var full := silhouette(body,3,false)
	var fps_before := silhouette(body,camera.cull_mask,false)
	var fps_after := silhouette(body,camera.cull_mask,true)
	var missing := 0
	for pixel in full:
		if not fps_after.has(pixel): missing += 1
	assert(full.size() > fps_before.size()*1.25,"Fixture must distinguish full body from legs")
	assert(missing == 0,"FPS shadow silhouette loses original body triangles")
	assert(fps_after.size() == full.size(),"Shadow proxies produce a different silhouette")
	for index in range(player.body_shadow_proxies.size()):
		var source: MeshInstance3D = player.body_shadow_sources[index]
		var proxy: MeshInstance3D = player.body_shadow_proxies[index]
		assert(proxy.mesh == source.mesh and proxy.skin == source.skin and proxy.skeleton == source.skeleton)
		assert(proxy.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY)
		var original := source.transform
		source.position.x += .02
		player.sync_body_shadow_proxies()
		assert(proxy.transform.is_equal_approx(source.transform))
		source.transform = original
	player.sync_body_shadow_proxies()
	print("SHADOW SILHOUETTE PASS: full=",full.size(),"px, FPS without proxies=",fps_before.size(),"px, corrected=",fps_after.size(),"px; missing=",missing,"; proxy count=",player.body_shadow_proxies.size(),". CPU triangle projection, GPU raster still requires capture.")
	if "--capture" in OS.get_cmdline_user_args():
		var ground := MeshInstance3D.new()
		var plane := PlaneMesh.new()
		plane.size = Vector2(8,8)
		ground.mesh = plane
		scene.add_child(ground)
		var light := DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-45,-30,0)
		light.shadow_enabled = true
		scene.add_child(light)
		var observer := Camera3D.new()
		scene.add_child(observer)
		observer.position = Vector3(3,4,4)
		observer.look_at(Vector3(0,.5,0))
		observer.cull_mask = camera.cull_mask
		observer.current = true
		await create_timer(.5).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../player_shadow_preview.png")
		print("SHADOW GPU CAPTURE: FPS mask, upper body invisible but casts complete shadow")
	scene.free()
	quit()
