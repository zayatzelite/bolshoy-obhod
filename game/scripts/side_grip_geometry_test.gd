extends "res://scripts/grip_geometry_test.gd"

# READ-ONLY candidate pose, not a natural-grasp claim or production change.
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
	var rig := Node3D.new()
	camera.add_child(rig)
	player.carry_rig=rig
	var hand: Node3D=load("res://assets/ranger_grip_detailed.glb").instantiate()
	rig.add_child(hand)
	hand.position=Vector3(.28,-.43,-.60)
	hand.scale=Vector3(1,1.65,1)
	hand.rotation.z=.12
	var grip: MeshInstance3D=hand.find_child("Detailed canvas grip",true,false)
	var tips: Array[Vector3] = []
	var palm_local := Vector3.ZERO
	var inverse := hand.global_transform.affine_inverse()
	for surface in range(grip.mesh.get_surface_count()):
		for points: PackedVector3Array in component_points(grip,surface):
			var bounds := points_bounds(points)
			if bounds.position.y > -.39 and bounds.position.z < -.70:
				var front := points[0]
				for point in points:
					if point.z<front.z:front=point
				tips.append(inverse*front)
			if surface==2 and bounds.size.y>.15:
				palm_local=inverse*bounds.get_center()
	assert(tips.size()==4 and palm_local!=Vector3.ZERO)
	print("LOCAL_PALM center=",palm_local," blender=",Vector3(palm_local.x,-palm_local.z,palm_local.y))
	for tip in tips:print("LOCAL_PAD ",tip," blender=",Vector3(tip.x,-tip.z,tip.y))
	for index in range(3):
		var item := Node3D.new()
		world.add_child(item)
		item.set_meta("title",ITEM_TITLES[index])
		var visual: Node3D=load(ITEM_PATHS[index]).instantiate()
		item.add_child(visual)
		world.place_in_hand(item)
		var body: MeshInstance3D=visual.find_child(["Bottle body","Can crushed body","Paper cup"][index],true,false)
		assert(body!=null)
		var mesh_to_item := item.global_transform.affine_inverse()*body.global_transform
		var bounds: AABB=mesh_to_item*body.mesh.get_aabb()
		var middle := bounds.get_center()
		var midworld := item.global_transform*middle
		# Turn finger length across the container. Wrist remains to the right.
		# Existing near-facing pads point along -Z and are not changed by Z rotation.
		hand.rotation=Vector3(0,0,item.rotation.z+PI*.5)
		var basis := hand.transform.basis
		# Palm starts on the right half of the cylinder, not underneath its bottom.
		var anchor := midworld+Vector3(bounds.size.x*.28,0,0)
		hand.position=anchor-basis*palm_local
		var required: Array[float]=[]
		for tip in tips:
			var point := hand.global_transform*tip
			var rear := rear_surface(visual,point)
			if is_finite(rear):required.append(point.z-rear)
		if required.size()==4:
			required.sort()
			hand.position.z-=(required[1]+required[2])*.5
		print("SIDE_CANDIDATE item=",index," body_local_bounds=",bounds," midbody_world=",midworld," palm_target=",anchor," hand_position=",hand.position," hand_rotation=",hand.rotation," hand_scale=",hand.scale," hit_pad_count=",required.size())
		var delta:=hand.position-Vector3(.28,-.43,-.60)
		print("SIDE_TRANSLATION_DELTA item=",index," ",delta)
		for tip in tips:
			var point := hand.global_transform*tip
			var item_local := item.global_transform.affine_inverse()*point
			var fraction := (item_local.y-bounds.position.y)/bounds.size.y
			var rear := rear_surface(visual,point)
			print("SIDE_PAD item=",index," world=",point," height_fraction=",fraction," rear_minus_pad_z=",rear-point.z)
		item.free()
	world.free()
	print("SIDE GRIP GEOMETRY COMPLETE: candidate horizontal side pose, not proof of natural grasp. All production files untouched.")
	quit()
