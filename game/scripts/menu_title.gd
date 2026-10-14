extends SubViewportContainer

func material(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.92
	return m

func mesh_node(world: Node, mesh: Mesh, pos: Vector3, mat: Material) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.mesh = mesh
	item.position = pos
	item.material_override = mat
	world.add_child(item)
	return item

func rock_mesh(radius: float, height: float, seed_id: int) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_id
	var rings: Array[PackedVector3Array] = []
	for j in range(7):
		var ring := PackedVector3Array()
		for i in range(9):
			var a := i*TAU/9.0
			var r := radius*(1.0-0.055*j)*rng.randf_range(0.84,1.13)
			ring.append(Vector3(cos(a)*r,height*j/6.0+ (rng.randf_range(-0.18,0.18) if j>0 else 0.0),sin(a)*r))
		rings.append(ring)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for j in range(6):
		for i in range(9):
			var k := (i+1)%9
			for v in [rings[j][i],rings[j+1][i],rings[j][k],rings[j][k],rings[j+1][i],rings[j+1][k]]:
				st.add_vertex(v)
	for i in range(9):
		for v in [Vector3(0,height,0),rings[6][(i+1)%9],rings[6][i]]:
			st.add_vertex(v)
	st.generate_normals()
	return st.commit()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	stretch = true
	var vp := SubViewport.new()
	vp.size = Vector2i(1280,720)
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	var world := Node3D.new()
	vp.add_child(world)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("4092c1")
	sky_mat.sky_horizon_color = Color("d6e6de")
	sky_mat.ground_horizon_color = Color("d6e6de")
	sky.sky_material = sky_mat
	env.environment.sky = sky
	env.environment.background_mode = Environment.BG_SKY
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("b6d2e1")
	env.environment.ambient_light_energy = 0.45
	world.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-32,-32,0)
	sun.light_color = Color("fff0d0")
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	world.add_child(sun)
	var camera := Camera3D.new()
	camera.position = Vector3(0,6,23)
	camera.fov = 48
	world.add_child(camera)
	camera.look_at(Vector3(0,3,0))
	var water := PlaneMesh.new()
	water.size = Vector2(160,160)
	var wm := material(Color("328f9f"))
	wm.roughness = 0.3
	wm.metallic = 0.25
	mesh_node(world,water,Vector3(0,-0.5,0),wm)
	var bank := BoxMesh.new()
	bank.size = Vector3(110,1.4,14)
	mesh_node(world,bank,Vector3(0,-0.2,-11),material(Color("597d4c")))
	for i in range(38):
		var height := 4.5+sin(i*1.63)*1.5+sin(i*0.49)*1.7
		mesh_node(world,rock_mesh(0.65,height,i+4),Vector3(-24+i*1.35,0.3,-10-sin(i)*1.4),material(Color("c1a27c").lightened((i%4)*0.025)))
	# Foreground bank; all vegetation belongs to ground, never the river.
	var shore := BoxMesh.new()
	shore.size = Vector3(15,1.2,13)
	mesh_node(world,shore,Vector3(-15,-0.3,12),material(Color("447349")))
	for i in range(22):
		var p := Vector3(-21+(i*2.73),0.5,-6.5)
		if i<8:
			p=Vector3(-18+(i%4)*2,0.3,9+(i/4)*3)
		var trunk := CylinderMesh.new()
		trunk.top_radius = 0.09
		trunk.bottom_radius = 0.15
		trunk.height = 2.3
		mesh_node(world,trunk,p+Vector3(0,1,0),material(Color("73563e")))
		for j in range(3):
			var crown := CylinderMesh.new()
			crown.top_radius = 0
			crown.bottom_radius = 0.9-j*0.17
			crown.height = 1.7
			crown.radial_segments = 9
			mesh_node(world,crown,p+Vector3(0,1.6+j*0.7,0),material(Color("326b50").lightened(j*0.05)))
	# Title is sculptural stone lettering: no grass, stand or floating turf.
	for row in range(2):
		var text := TextMesh.new()
		text.text = "ЛЕНСКИЕ" if row==0 else "СТОЛБЫ"
		var font := SystemFont.new()
		font.font_names = PackedStringArray(["Arial Black","Arial"])
		font.font_weight = 900
		text.font = font
		text.font_size = 128
		text.pixel_size = 0.0105
		text.depth = 0.45
		var letters := mesh_node(world,text,Vector3(3.1,5.25-row*1.35,4),material(Color("dfc496")))
		letters.rotation_degrees = Vector3(-3,-8,0)
