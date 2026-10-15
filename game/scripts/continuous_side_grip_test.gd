extends "res://scripts/grip_pose_test.gd"

# Per-region measurements on the current continuous per-item GLBs; no production edits.
func run() -> void:
	var failures: Array[String] = []
	# A frontmost vertex may be buried (positive signed depth) or floating
	# (negative depth). 5 mm is 25–50% of the measured distal pad depth/radius:
	# beyond that a contact is not convincingly fitted, even if nearest rim is close.
	const MAX_CONTACT_ERROR_M := .005
	var world := Node3D.new()
	root.add_child(world)
	world.set_script(WORLD_SCRIPT)
	var player := CharacterBody3D.new()
	world.add_child(player)
	player.set_script(PLAYER_SCRIPT)
	world.player=player
	player.set_process(false)
	player.set_physics_process(false)
	world.set_process(false)
	world.set_physics_process(false)
	var camera:=Camera3D.new()
	player.add_child(camera)
	player.camera=camera
	player.make_carrying_hand()
	for index in range(3):
		var key: String=["bottle","can","cup"][index]
		var hand: Node3D=player.grip_variants[key]
		var item:=Node3D.new()
		world.add_child(item)
		item.set_meta("title",ITEM_TITLES[index])
		var visual: Node3D=load(ITEM_PATHS[index]).instantiate()
		item.add_child(visual)
		world.place_in_hand(item)
		print("POSE ",key," hand=",hand.transform," item=",item.transform)
		var regions: Array=[]
		for region in range(5):regions.append(PackedVector3Array())
		for mesh: MeshInstance3D in hand.find_children("*","MeshInstance3D",true,false):
			print("MESH ",key," ",mesh.name," aabb=",hand.global_transform.affine_inverse()*mesh.global_transform*mesh.mesh.get_aabb())
			# Do not identify fingers by disconnected topology: continuous cloth has none.
			if not (str(mesh.name).to_lower().contains("grip") or str(mesh.name).to_lower().contains("glove")):continue
			for surface in range(mesh.mesh.get_surface_count()):
				var arrays:=mesh.mesh.surface_get_arrays(surface)
				var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
				for vertex in vertices:
					var local:=hand.global_transform.affine_inverse()*mesh.global_transform*vertex
					if local.y>.03 and local.z<-.085:
						var region:=clampi(int(floor((local.x+.0585)/.0292)),0,3)
						regions[region].append(local)
					elif local.x<-.035 and local.y>-.02 and local.y<.035 and local.z<-.10:
						regions[4].append(local)
		for region in range(5):
			var points: PackedVector3Array=regions[region]
			if points.is_empty():
				print("EMPTY_REGION ",key," ",region)
				failures.append("%s region %d missing anatomical samples" % [key,region])
				continue
			var front:=points[0]
			for point in points:
				if point.z<front.z:front=point
			var actual:=hand.global_transform*front
			var target:=closest_surface(visual,actual)
			var local_delta:=hand.global_transform.basis.inverse()*(target-actual)
			var blender_delta:=Vector3(local_delta.x,-local_delta.z,local_delta.y)
			var rear:=rear_surface(visual,actual)
			if not is_finite(rear):
				failures.append("%s region %d ray misses body" % [key,region])
			elif absf(rear-actual.z)>MAX_CONTACT_ERROR_M:
				failures.append("%s region %d signed depth %.2f mm exceeds 5 mm" % [key,region,(rear-actual.z)*1000])
			if actual.distance_to(target)>MAX_CONTACT_ERROR_M:
				failures.append("%s region %d nearest triangle distance %.2f mm exceeds 5 mm" % [key,region,actual.distance_to(target)*1000])
			if is_finite(rear):
				var world_target := Vector3(actual.x,actual.y,rear)
				var rear_delta := hand.global_transform.basis.inverse()*(world_target-actual)
				print("RAY_CONTACT ",key," ",region," has_front_hit=true blender_delta_same_xy=",Vector3(rear_delta.x,-rear_delta.z,rear_delta.y))
			else:
				print("RAY_CONTACT ",key," ",region," has_front_hit=false: depth-only correction invalid, do not snap to nearest rim")
			print("REGION ",key," ",region," count=",points.size()," bounds=",points_bounds(points)," local_front=",front," blender_front=",Vector3(front.x,-front.z,front.y)," world=",actual," nearest_target=",target," distance_m=",actual.distance_to(target)," delta_blender=",blender_delta," rear_minus_pad_z=",rear-actual.z)
		item.free()
	world.free()
	print("CONTINUOUS SIDE MEASURE COMPLETE: region filters are anatomical coordinate heuristics, not disconnected parts; nearest triangle is NOT a natural-wrap validation.")
	if not failures.is_empty():
		for failure in failures: print("CONTACT FAILURE: ",failure)
		print("CONTINUOUS CONTACT FAIL: ",failures.size()," checks exceed geometric tolerances. No natural-grasp claim.")
		quit(1)
	else:
		print("CONTINUOUS CONTACT GEOMETRY PASS: five representative region fronts each within 5 mm; visual/natural-grasp review still required.")
		quit()
