extends "res://scripts/grip_geometry_test.gd"

# Read-only extension of geometry probe: thumb nearest triangle and Blender delta.
func closest_triangle(point: Vector3, a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	var normal := (b-a).cross(c-a).normalized()
	var projected := point-normal*normal.dot(point-a)
	var ab := (b-a).cross(projected-a).dot(normal)
	var bc := (c-b).cross(projected-b).dot(normal)
	var ca := (a-c).cross(projected-c).dot(normal)
	if ab >= -.0000001 and bc >= -.0000001 and ca >= -.0000001: return projected
	var best := Geometry3D.get_closest_point_to_segment(point,a,b)
	for candidate in [Geometry3D.get_closest_point_to_segment(point,b,c), Geometry3D.get_closest_point_to_segment(point,c,a)]:
		if candidate.distance_squared_to(point) < best.distance_squared_to(point): best = candidate
	return best

func closest_surface(node: Node3D, point: Vector3) -> Vector3:
	var best := Vector3.ONE*1000
	for mesh: MeshInstance3D in node.find_children("*","MeshInstance3D",true,false):
		for surface in range(mesh.mesh.get_surface_count()):
			var arrays := mesh.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			for t in range(0,indices.size(),3):
				var candidate := closest_triangle(point,mesh.global_transform*vertices[indices[t]],mesh.global_transform*vertices[indices[t+1]],mesh.global_transform*vertices[indices[t+2]])
				if candidate.distance_squared_to(point)<best.distance_squared_to(point):best=candidate
	return best

func run() -> void:
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
	var camera := Camera3D.new()
	player.add_child(camera)
	player.camera=camera
	player.make_carrying_hand()
	var hand: Node3D=player.carrying_hand
	var grip: MeshInstance3D=hand.find_child("Detailed canvas grip",true,false)
	var thumb_tip := Vector3.ZERO
	var found := false
	for surface in range(grip.mesh.get_surface_count()):
		for points: PackedVector3Array in component_points(grip,surface):
			var bounds := points_bounds(points)
			if bounds.end.x < .25 and bounds.position.y < -.39 and bounds.position.z < -.67:
				var foremost := points[0]
				for point in points:
					if point.z<foremost.z:foremost=point
				print("THUMB_COMPONENT bounds=",bounds," foremost=",foremost," hand_local=",hand.global_transform.affine_inverse()*foremost)
				if not found or foremost.z < thumb_tip.z:
					thumb_tip=foremost
					found=true
	assert(found,"Thumb classifier no longer fits asset: inspect after remesh")
	for index in range(3):
		var item := Node3D.new()
		world.add_child(item)
		item.set_meta("title",ITEM_TITLES[index])
		var visual: Node3D=load(ITEM_PATHS[index]).instantiate()
		item.add_child(visual)
		world.place_in_hand(item)
		var closest := closest_surface(visual,thumb_tip)
		var delta := closest-thumb_tip
		var local_delta := hand.global_transform.basis.inverse()*delta
		# Standard glTF exporter maps Blender (x,y,z) to Godot (x,z,-y).
		var blender_delta := Vector3(local_delta.x,-local_delta.z,local_delta.y)
		var target_local := hand.global_transform.affine_inverse()*closest
		print("THUMB_CONTACT item=",index," position=",item.position," tip=",thumb_tip," target=",closest," nearest_distance_m=",delta.length()," delta_world=",delta," delta_hand_local=",local_delta," delta_blender=",blender_delta," target_blender=",Vector3(target_local.x,-target_local.z,target_local.y))
		item.free()
	world.free()
	print("GRIP POSE PASS: measured actual thumb vertices against current production item transforms; no player/assets/world changed. Nearest surface is a candidate contact, not proof of natural grasp.")
	quit()
