extends RefCounted
static func edge(z: float) -> float:return 49.0+1.8*sin(z*.035)+.6*sin(z*.11)
static func vertex(x: float,z: float,t: float) -> Vector3:
	var ground := .12*sin(x*.12)*sin(-z*.08)+.035
	return Vector3(x,lerpf(ground,-.64,maxf(0,(t-.75)*4)),z)
static func build() -> MeshInstance3D:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(130):
		var z := 35.0-index*2
		var next_z := z-2
		var a := vertex(edge(z),z,0)
		var b := vertex(edge(next_z),next_z,0)
		var c := vertex(57,z,1)
		var d := vertex(57,next_z,1)
		var e := vertex(55,z,.75)
		var f := vertex(55,next_z,.75)
		for p in [a,b,e,b,f,e,e,f,c,f,d,c]:surface.add_vertex(p)
	surface.generate_normals()
	var bank := MeshInstance3D.new()
	bank.name = "Sandy riverbank"
	bank.mesh = surface.commit()
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/trail_ground.gdshader")
	bank.material_override = material
	var pebbles := MultiMeshInstance3D.new()
	var instances := MultiMesh.new()
	instances.transform_format = MultiMesh.TRANSFORM_3D
	var pebble := SphereMesh.new()
	pebble.radial_segments = 8
	pebble.rings = 4
	pebble.radius = 1
	pebble.height = 2
	instances.mesh = pebble
	instances.instance_count = 420
	var rng := RandomNumberGenerator.new()
	rng.seed = 9172
	for index in range(420):
		var z := rng.randf_range(-218,24)
		var x := rng.randf_range(edge(z)+.5,54.6)
		var radius := rng.randf_range(.045,.18)
		var position := vertex(x,z,.5)+Vector3(0,radius*.3,0)
		var basis := Basis(Vector3.UP,rng.randf_range(0,TAU)).scaled(Vector3(radius,radius*.45,radius*.75))
		instances.set_instance_transform(index,Transform3D(basis,position))
	pebbles.multimesh = instances
	var stone := StandardMaterial3D.new()
	stone.albedo_color = Color("8b8674")
	stone.roughness = 1
	pebbles.material_override = stone
	bank.add_child(pebbles)
	return bank

static func distant_bank() -> MeshInstance3D:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(90):
		var z := 80.0-index*4
		var nz := z-4
		var a := Vector3(114+sin(z*.035),-.62,z)
		var b := Vector3(114+sin(nz*.035),-.62,nz)
		var c := Vector3(145,2.0+sin(z*.04)*.7,z)
		var d := Vector3(145,2.0+sin(nz*.04)*.7,nz)
		for p in [a,b,c,b,d,c]:surface.add_vertex(p)
	surface.generate_normals()
	var mesh := MeshInstance3D.new()
	mesh.name = "Distant river shore"
	mesh.mesh = surface.commit()
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("617457")
	material.roughness = 1
	mesh.material_override = material
	var scree := SurfaceTool.new()
	scree.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(70):
		var z := -28.0-index*2
		var nz := z-2
		var a := Vector3(scree_edge(z),.12,z)
		var b := Vector3(scree_edge(nz),.12,nz)
		var c := Vector3(140,scree_height(z),z)
		var d := Vector3(140,scree_height(nz),nz)
		for p in [a,b,c,b,d,c]:scree.add_vertex(p)
	scree.generate_normals()
	var footing := MeshInstance3D.new()
	footing.name = "Pillar scree foothill"
	footing.mesh = scree.commit()
	var limestone := StandardMaterial3D.new()
	limestone.albedo_color = Color("737166")
	limestone.roughness = 1
	footing.material_override = limestone
	mesh.add_child(footing)
	var massif_surface := SurfaceTool.new()
	massif_surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(70):
		var z := -28.0-index*2
		var nz := z-2
		var a := Vector3(137,scree_height(z),z)
		var b := Vector3(137,scree_height(nz),nz)
		var c := Vector3(151,massif_height(z),z)
		var d := Vector3(151,massif_height(nz),nz)
		var e := Vector3(169,hill_height(z)+2,z)
		var f := Vector3(169,hill_height(nz)+2,nz)
		for p in [a,b,c,b,d,c,c,d,e,d,f,e]:massif_surface.add_vertex(p)
	massif_surface.generate_normals()
	var massif := MeshInstance3D.new()
	massif.name = "Incised limestone valley backing"
	massif.mesh = massif_surface.commit()
	var rock_material := ShaderMaterial.new()
	rock_material.shader = preload("res://shaders/limestone.gdshader")
	massif.material_override = rock_material
	mesh.add_child(massif)
	massif.create_trimesh_collision()
	var hills := SurfaceTool.new()
	hills.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(90):
		var z := 80.0-index*4
		var nz := z-4
		var a := Vector3(145,2+sin(z*.04)*.7,z)
		var b := Vector3(145,2+sin(nz*.04)*.7,nz)
		var c := Vector3(175,hill_height(z),z)
		var d := Vector3(175,hill_height(nz),nz)
		for p in [a,b,c,b,d,c]:hills.add_vertex(p)
	hills.generate_normals()
	var hillside := MeshInstance3D.new()
	hillside.name = "Far shore rolling hills"
	hillside.mesh = hills.commit()
	hillside.material_override = material
	mesh.add_child(hillside)
	var forest := MultiMeshInstance3D.new()
	forest.name = "Far shore forest silhouette"
	var trees := MultiMesh.new()
	trees.transform_format = MultiMesh.TRANSFORM_3D
	trees.mesh = forest_crown_mesh()
	trees.instance_count = 180
	var trunks := MultiMesh.new()
	trunks.transform_format = MultiMesh.TRANSFORM_3D
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = .11
	trunk_mesh.bottom_radius = .16
	trunk_mesh.height = 1.2
	trunk_mesh.radial_segments = 8
	trunks.mesh = trunk_mesh
	trunks.instance_count = 180
	var rng := RandomNumberGenerator.new()
	rng.seed = 29217
	for i in range(180):
		var z := rng.randf_range(-275,75)
		var x := rng.randf_range(172,175) if z>=-171 and z<=-25 else rng.randf_range(146,175)
		var ground := far_hill_surface_height(x,z)
		var scale_value := rng.randf_range(.7,1.6)
		var tree_basis := Basis.IDENTITY.scaled(Vector3.ONE*scale_value)
		trees.set_instance_transform(i,Transform3D(tree_basis,Vector3(x,ground+3.4*scale_value,z)))
		trunks.set_instance_transform(i,Transform3D(tree_basis,Vector3(x,ground+.6*scale_value,z)))
	forest.multimesh = trees
	var needles := StandardMaterial3D.new()
	needles.albedo_color = Color("385449")
	needles.roughness = 1
	forest.material_override = needles
	mesh.add_child(forest)
	var stems := MultiMeshInstance3D.new()
	stems.name = "Far shore tree trunks"
	stems.multimesh = trunks
	var bark := StandardMaterial3D.new()
	bark.albedo_color = Color("65523c")
	bark.roughness = 1
	stems.material_override = bark
	mesh.add_child(stems)
	var slope_crowns := MultiMesh.new()
	slope_crowns.transform_format = MultiMesh.TRANSFORM_3D
	slope_crowns.mesh = trees.mesh
	var slope_trunks := MultiMesh.new()
	slope_trunks.transform_format = MultiMesh.TRANSFORM_3D
	slope_trunks.mesh = trunks.mesh
	slope_crowns.instance_count = 240
	slope_trunks.instance_count = 240
	for i in range(240):
		var z := rng.randf_range(-164,-30)
		var x := rng.randf_range(152,168)
		var ground := rear_slope_height(x,z)
		var scale_value := rng.randf_range(.55,1.1)
		var tree_basis := Basis.IDENTITY.scaled(Vector3.ONE*scale_value)
		slope_crowns.set_instance_transform(i,Transform3D(tree_basis,Vector3(x,ground+3.4*scale_value,z)))
		slope_trunks.set_instance_transform(i,Transform3D(tree_basis,Vector3(x,ground+.6*scale_value,z)))
	var slope_forest := MultiMeshInstance3D.new()
	slope_forest.name = "Limestone rear slope forest"
	slope_forest.multimesh = slope_crowns
	slope_forest.material_override = needles
	mesh.add_child(slope_forest)
	var slope_stems := MultiMeshInstance3D.new()
	slope_stems.name = "Limestone rear slope trunks"
	slope_stems.multimesh = slope_trunks
	slope_stems.material_override = bark
	mesh.add_child(slope_stems)
	return mesh

static func far_hill_surface_height(x: float,z: float) -> float:
	var top_z := 80.0-floorf((80-z)/4)*4
	var u := (x-145)/30
	var v := (top_z-z)/4
	var a := 2+sin(top_z*.04)*.7
	var b := 2+sin((top_z-4)*.04)*.7
	var c := hill_height(top_z)
	var d := hill_height(top_z-4)
	if u+v<=1:return a*(1-u-v)+b*v+c*u
	return b*(1-u)+d*(u+v-1)+c*(1-v)

static func forest_crown_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for tier in range(3):
		var bottom := -2.5+tier*1.25
		var radius := 1.3-tier*.32
		var tip := Vector3(0,bottom+2.5,0)
		for i in range(9):
			var angle := i*TAU/9.0
			var next_angle := (i+1)*TAU/9.0
			var a := Vector3(cos(angle)*radius,bottom+.12*sin(i*2.3+tier),sin(angle)*radius)
			var b := Vector3(cos(next_angle)*radius,bottom+.12*sin((i+1)*2.3+tier),sin(next_angle)*radius)
			for p in [a,tip,b]:surface.add_vertex(p)
	surface.generate_normals()
	return surface.commit()

static func rear_slope_height(x: float,z: float) -> float:
	var segment := floorf((-z-28)/2)
	var top_z := -28-segment*2
	var u := (x-151)/18
	var v := (top_z-z)/2
	var a := massif_height(top_z)
	var b := massif_height(top_z-2)
	var c := hill_height(top_z)+2
	var d := hill_height(top_z-2)+2
	if u+v<=1:return a*(1-u-v)+b*v+c*u
	return b*(1-u)+d*(u+v-1)+c*(1-v)

static func massif_height(z: float) -> float:
	var cell := floorf((-z-28.0)/6.0)
	var irregular := fposmod(sin(cell*73.17+19.2)*43758.5453,1.0)
	var notch := pow(absf(sin(z*.075)),1.8)
	var taper := smoothstep(0.0,14.0,minf(-z-28.0,z+168.0))
	return lerpf(2.0+sin(z*.04)*.7,7.0+notch*10.0+floorf(irregular*4.0)*1.4,taper)

static func scree_edge(z: float) -> float:
	return 122.0+2.8*sin(z*.13)+1.4*sin(z*.37)

static func scree_height(z: float) -> float:
	var taper := smoothstep(0.0,10.0,minf(-z-28.0,z+168.0))
	return lerpf(.12,4.0+3.5*pow(absf(sin(z*.095)),1.5)+.8*sin(z*.41),taper)

static func hill_height(z: float) -> float:
	return 5.0+2.2*sin(z*.033)+1.1*sin(z*.071)
