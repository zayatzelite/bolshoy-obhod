extends Node3D
# Decorative meadow accents only; not species records or educational targets.
var flower_count := 0
var planting_points: PackedVector3Array = []
func build(world: Node3D, landscape: Node3D) -> void:
	var blocked: Array[AABB] = []
	for node in landscape.get_children():
		if node is MeshInstance3D and (str(node.name).begins_with("Cliff fin") or str(node.name).begins_with("Scree boulder") or str(node.name).begins_with("Trail limestone gallery") or str(node.name).begins_with("Tree trunk") or str(node.name).begins_with("Trail understory shrub")):
			blocked.append((node.global_transform*node.get_aabb()).grow(.4))
	var rng := RandomNumberGenerator.new()
	rng.seed = 85123
	var tools: Array[SurfaceTool] = []
	for group in range(3):
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		tools.append(surface)
	for attempt in range(2400):
		var x := rng.randf_range(-40,40)
		var d := rng.randf_range(10,185)
		var y := .12*sin(x*.12)*sin(d*.08)+maxf(0,(-x-15)*.025)*(.5+.5*sin(d*.025))
		var center := Vector3(x,y,-d)
		if world.grass_excluded(center):continue
		if absf(x-2.5*sin(d*.035))<3.3:continue
		if d>=55 and d<=155 and absf(x-(2.5*sin(d*.035)-22*sin((d-55)*PI/100)))<2.4:continue
		var occupied := false
		for box in blocked:
			if x>box.position.x and x<box.end.x and -d>box.position.z and -d<box.end.z:occupied = true;break
		if occupied:continue
		var surface := tools[attempt%3]
		var height := rng.randf_range(.22,.48)
		var top := center+Vector3(0,height,0)
		for vertex in [center+Vector3(-.012,0,0),top+Vector3(.012,0,0),top+Vector3(-.012,0,0),center+Vector3(-.012,0,0),center+Vector3(.012,0,0),top+Vector3(.012,0,0)]:
			surface.set_color(Color("536934"));surface.add_vertex(vertex)
		for side in [-1,1]:
			var leaf_root := center+Vector3(0,height*.45,0)
			for vertex in [leaf_root,leaf_root+Vector3(side*.14,.065,.025),leaf_root+Vector3(side*.06,.015,-.035)]:
				surface.set_color(Color("65783d"));surface.add_vertex(vertex)
		for petal in range(6):
			var a := petal*TAU/6
			var radial := Vector3(cos(a),0,sin(a))
			var tangent := Vector3(-sin(a),0,cos(a))
			for vertex in [top,top+radial*.07+tangent*.035+Vector3(0,.015,0),top+radial*.12+Vector3(0,.045,0),top,top+radial*.12+Vector3(0,.045,0),top+radial*.07-tangent*.035+Vector3(0,.015,0)]:
				surface.set_color([Color("e6d6a4"),Color("a891c4"),Color("e0b84b")][attempt%3]);surface.add_vertex(vertex)
			var b := (petal+1)*TAU/6
			for vertex in [top+Vector3(0,.008,0),top+Vector3(cos(b)*.026,.012,sin(b)*.026),top+radial*.026+Vector3(0,.012,0)]:
				surface.set_color(Color("c69439"));surface.add_vertex(vertex)
		flower_count+=1
		planting_points.append(center)
	for surface in tools:
		surface.generate_normals()
		var visual := MeshInstance3D.new()
		visual.mesh = surface.commit()
		var material := StandardMaterial3D.new()
		material.vertex_color_use_as_albedo = true
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.roughness = 1
		visual.material_override = material
		add_child(visual)
