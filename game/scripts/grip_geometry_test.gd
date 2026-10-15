extends SceneTree

# Read-only static geometry probe. Run with --headless --script.
# This deliberately avoids world creation, threaded loading, saves and rendering.
# AABB overlap alone does NOT establish a contact: rays sample the actual triangles.
const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const WORLD_SCRIPT = preload("res://scripts/world.gd")
const ITEM_PATHS = ["res://assets/litter_bottle.glb", "res://assets/litter_can.glb", "res://assets/litter_cup.glb"]
const ITEM_TITLES = ["Пластиковая бутылка", "Смятая банка", "Бумажный стакан"]

func _initialize() -> void:
	call_deferred("run")

func component_points(mesh: MeshInstance3D, surface: int) -> Array:
	var arrays := mesh.mesh.surface_get_arrays(surface)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var parents: Array[int] = []
	for i in range(vertices.size()): parents.append(i)
	# GLB UV/material seams can duplicate a position, so weld for connectivity only.
	var welded := {}
	for i in range(vertices.size()):
		var key := str(vertices[i].snapped(Vector3.ONE * .000001))
		if welded.has(key): parents[i] = welded[key]
		else: welded[key] = i
	for t in range(0, indices.size(), 3):
		for j in range(1, 3):
			var a := indices[t]
			var b := indices[t+j]
			while parents[a] != a: a = parents[a]
			while parents[b] != b: b = parents[b]
			parents[b] = a
	var components := {}
	for i in range(vertices.size()):
		var ancestor := i
		while parents[ancestor] != ancestor: ancestor = parents[ancestor]
		if not components.has(ancestor): components[ancestor] = PackedVector3Array()
		components[ancestor].append(mesh.global_transform * vertices[i])
	return components.values()

func points_bounds(points: PackedVector3Array) -> AABB:
	var bounds := AABB(points[0], Vector3.ZERO)
	for point in points: bounds = bounds.expand(point)
	return bounds

func rear_surface(node: Node3D, point: Vector3) -> float:
	var rear := -INF
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		for surface in range(mesh.mesh.get_surface_count()):
			var arrays := mesh.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			for t in range(0, indices.size(), 3):
				var hit = Geometry3D.ray_intersects_triangle(Vector3(point.x, point.y, 1), Vector3(0,0,-1), mesh.global_transform * vertices[indices[t]], mesh.global_transform * vertices[indices[t+1]], mesh.global_transform * vertices[indices[t+2]])
				if hit != null: rear = maxf(rear, hit.z)
	return rear

func run() -> void:
	# Set scripts only AFTER these plain nodes enter the tree: no production _ready.
	# Then call the real construction/placement methods, not a duplicated transform.
	var world := Node3D.new()
	root.add_child(world)
	world.set_script(WORLD_SCRIPT)
	var player := CharacterBody3D.new()
	world.add_child(player)
	player.set_script(PLAYER_SCRIPT)
	world.player = player
	player.set_process(false)
	player.set_physics_process(false)
	world.set_process(false)
	world.set_physics_process(false)
	var camera := Camera3D.new()
	player.add_child(camera)
	player.camera = camera
	player.make_carrying_hand()
	var hand: Node3D = player.carrying_hand
	assert(player.carry_rig.get_parent() == camera)
	assert(hand.get_parent() == player.carry_rig)
	for mesh: MeshInstance3D in hand.find_children("*", "MeshInstance3D", true, false):
		assert(mesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	var grip: MeshInstance3D = hand.find_child("Detailed canvas grip", true, false)
	assert(grip != null)
	print("HAND transform=",hand.transform," AABB=",grip.global_transform * grip.mesh.get_aabb())
	var tips: Array[Vector3] = []
	for surface in range(grip.mesh.get_surface_count()):
		for points: PackedVector3Array in component_points(grip, surface):
			var bounds := points_bounds(points)
			# Four separate distal-pad shells, excluding palm, thumb and stitches.
			if bounds.position.y > -.39 and bounds.position.z < -.70:
				var front := points[0]
				for point in points:
					if point.z < front.z: front = point
				tips.append(front)
				print("DISTAL_PAD AABB=",bounds," foremost_vertex=",front)
	assert(tips.size() == 4, "Asset changed: inspect the distal-pad classifier before using recommendations")
	tips.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.x < b.x)
	for index in range(3):
		var item := Node3D.new()
		world.add_child(item)
		item.set_meta("title", ITEM_TITLES[index])
		var visual: Node3D = load(ITEM_PATHS[index]).instantiate()
		item.add_child(visual)
		world.place_in_hand(item)
		print("ITEM ",index," current_transform=",item.transform)
		var shifts: Array[float] = []
		for tip in tips:
			var rear := rear_surface(visual, tip)
			assert(is_finite(rear), "Fingertip ray misses item; translation-only fit is not valid")
			shifts.append(tip.z-rear)
			print("CONTACT item=",index," tip=",tip," rear_z=",rear," needed_delta_z=",tip.z-rear)
		shifts.sort()
		var recommended := (shifts[1]+shifts[2])*.5
		print("RECOMMEND item=",index," median_delta_z=",recommended," proposed_absolute_z=",item.position.z+recommended," range=",shifts[0],"..",shifts[3])
		# Evaluate lateral centering numerically without altering production offsets.
		var original_x := item.position.x
		var best_spread := INF
		var best_x := 0.0
		var best_z := 0.0
		for step in range(-20, 21, 2):
			item.position.x = original_x + step * .001
			var candidate: Array[float] = []
			for tip in tips:
				var rear := rear_surface(visual, tip)
				if is_finite(rear): candidate.append(tip.z-rear)
			if candidate.size() != 4: continue
			candidate.sort()
			var spread := candidate[3]-candidate[0]
			if spread < best_spread:
				best_spread = spread
				best_x = step * .001
				best_z = (candidate[1]+candidate[2])*.5
		print("LATERAL_FIT item=",index," delta_x=",best_x," delta_z=",best_z," pad_depth_spread=",best_spread)
		item.position.x = original_x
		# Re-sample after translation to verify the proposed correction numerically.
		item.position.z += recommended
		for tip in tips:
			print("RESIDUAL item=",index," surface_minus_tip_z=",rear_surface(visual,tip)-tip.z)
		item.free()
	world.free()
	print("GRIP GEOMETRY PASS: four real pad vertices, three production item transforms. Recommendations require visual review; no world or asset modified.")
	quit()
