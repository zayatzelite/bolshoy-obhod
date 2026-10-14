extends SceneTree
var rocks: Array[MeshInstance3D] = []
func gather(node: Node) -> void:
	if node is MeshInstance3D and (str(node.name).begins_with("Cliff fin") or str(node.name).begins_with("Trail limestone gallery")):rocks.append(node)
	for child in node.get_children():gather(child)
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await physics_frame
	await physics_frame
	gather(scene)
	assert(rocks.size()>50)
	for rock in rocks:
		var body: StaticBody3D
		for child in rock.get_children():
			if child is StaticBody3D:body = child
		assert(is_instance_valid(body),str(rock.name))
		var bounds := rock.mesh.get_aabb()
		var middle: Vector3 = rock.global_transform*bounds.get_center()
		if str(rock.name).begins_with("Cliff fin"):
			assert(middle.x>115 and middle.x<155,"Main pillars must be beyond river")
		var query := PhysicsRayQueryParameters3D.create(middle-Vector3(30,0,0),middle+Vector3(30,0,0),1)
		var excluded: Array[RID] = []
		for other in scene.find_children("*","CollisionObject3D",true,false):
			if other!=body:excluded.append(other.get_rid())
		query.exclude = excluded
		var hit: Dictionary = scene.get_world_3d().direct_space_state.intersect_ray(query)
		assert(not hit.is_empty(),"No horizontal collision at "+str(rock.name))
		assert(hit.collider==body,"Ray blocked by another object instead of target rock")
	print("ROCK COLLISION PASS: ",rocks.size()," rock meshes have static bodies and horizontal blocking hits")
	quit()
