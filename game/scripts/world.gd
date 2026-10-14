extends Node3D

const Settings = preload("res://scripts/game_settings.gd")
const PlayerScript = preload("res://scripts/player.gd")
var player: CharacterBody3D
var cart: CharacterBody3D
var cargo := 0
var delivered := 0
var collected := 0
var rubbish: Array[Node3D] = []
var hud: Control
var experience := 0
var progression := preload("res://scripts/progression.gd").new()
var prompt: Label
var message: Label
var ui: Control
var overlay: PanelContainer
var sun: DirectionalLight3D
var message_timer := 0.0
var wheels: Array[MeshInstance3D] = []
var held_item: Node3D
var inventory: Array[Node3D] = []
var focused_item: Node3D
var outline_material: ShaderMaterial
var plant_catalog := preload("res://scripts/plant_catalog.gd").new()
var focused_species := ""
var focused_plant: Node3D
var observed_species: Dictionary = {}
var session_seconds := 0.0
var walked_distance := 0.0
var last_player_position := Vector3.ZERO
var session_xp := 0
var results_shown := false
var settings_refresh_timer := 0.0
var moving_clouds: Array[Node3D] = []
var cloud_origins: Array[Vector3] = []
var cloud_time := 0.0
var retained_cabin_materials: Array[Material] = []
var forest_tier_mesh: ArrayMesh
var animated_materials: Array[ShaderMaterial] = []
var effect_time := 0.0
const INVENTORY_CAPACITY := 3
var bases := [Vector3(-8,0,1),Vector3(30,0,-155)]
var delivery_points := [Vector3(-8,0,6.4),Vector3(30,0,-149.6)]

func is_patrol_paused() -> bool:
	return Input.mouse_mode!=Input.MOUSE_MODE_CAPTURED or (is_instance_valid(overlay) and not overlay.is_queued_for_deletion())

func near_delivery() -> Vector3:
	for point in delivery_points:
		if player.position.distance_to(point)<3.5:return point
	return Vector3(9999,0,0)

func mat(color: String) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(color)
	m.roughness = 0.85
	return m

func part(parent: Node3D, geometry: Mesh, at: Vector3, material: Material, solid: bool = false) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	mesh.mesh = geometry
	mesh.position = at
	mesh.material_override = material
	parent.add_child(mesh)
	if solid:
		mesh.create_trimesh_collision()
	return mesh

func box(parent: Node3D, at: Vector3, dimensions: Vector3, color: String, solid: bool = false) -> MeshInstance3D:
	var geometry := BoxMesh.new()
	geometry.size = dimensions
	return part(parent, geometry, at, mat(color), solid)

func detailed_forest_mesh() -> ArrayMesh:
	if forest_tier_mesh:return forest_tier_mesh
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for tier in range(5):
		var base := -.5+tier*.17
		var radius := .5*(1.0-tier*.16)
		for segment in range(18):
			var a := segment*TAU/18
			var b := (segment+1)*TAU/18
			var r1 := radius*(1+.09*sin(segment*2.2+tier))
			var r2 := radius*(1+.09*sin((segment+1)*2.2+tier))
			surface.add_vertex(Vector3(cos(a)*r1,base,sin(a)*r1))
			surface.add_vertex(Vector3(0,minf(.5,base+.36),0))
			surface.add_vertex(Vector3(cos(b)*r2,base,sin(b)*r2))
	surface.generate_normals()
	forest_tier_mesh = surface.commit()
	return forest_tier_mesh

func grass_excluded(p: Vector3) -> bool:
	if preload("res://scripts/base_approach.gd").excluded(p) or preload("res://scripts/shore_connector.gd").excluded(p):return true
	if p.z>=-195 and p.z<=3 and absf(p.x-2.5*sin(-p.z*.035))<1.9:return true
	for base in bases:
		if absf(p.x-base.x)<4.8 and p.z>base.z-4.2 and p.z<base.z+8.8:return true
	if p.z<=-20 and p.z>=-65:
		var d := -p.z
		var center: Vector3 = preload("res://scripts/exploration_path.gd").point(d)
		var tangent: Vector3 = preload("res://scripts/exploration_path.gd").point(d+.1)-center
		var width := 1.45*sqrt(1+pow(tangent.x/.1,2))
		if absf(p.x-center.x)<width:return true
	for rest_z in [-40.0,-95.0,-155.0]:
		if absf(p.x+6)<2.3 and p.z>rest_z-2.1 and p.z<rest_z+.4:return true
		if Vector2(p.x+9.4,p.z-rest_z).length()<.6:return true
	return false

func clear_base_grass(node: MeshInstance3D) -> void:
	var replacement := ArrayMesh.new()
	for surface in range(node.mesh.get_surface_count()):
		var arrays := node.mesh.surface_get_arrays(surface)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var source: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		if source.is_empty():
			for index in range(vertices.size()):source.append(index)
		var kept := PackedInt32Array()
		for face in range(0,source.size(),3):
			var blocked := false
			for corner in range(3):
				var p: Vector3 = node.global_transform*vertices[source[face+corner]]
				if grass_excluded(p):blocked = true
			if not blocked:kept.append_array(PackedInt32Array([source[face],source[face+1],source[face+2]]))
		if kept.is_empty():continue
		arrays[Mesh.ARRAY_INDEX] = kept
		replacement.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		replacement.surface_set_material(replacement.get_surface_count()-1,node.mesh.surface_get_material(surface))
	node.mesh = replacement

func intersects_new_route(bounds: AABB) -> bool:
	var footprint := Rect2(Vector2(bounds.position.x,bounds.position.z),Vector2(bounds.size.x,bounds.size.z)).grow(.3)
	var base_footprint := Rect2(Vector2(bases[1].x-6,bases[1].z-10),Vector2(12,20))
	if footprint.intersects(base_footprint):return true
	for distance in range(-3,196):
		var center := Vector2(2.5*sin(distance*.035),-distance)
		if footprint.grow(1.9).has_point(center):return true
	for distance in range(20,66):
		var center: Vector3 = preload("res://scripts/exploration_path.gd").point(distance)
		if footprint.grow(1.7).has_point(Vector2(center.x,center.z)):return true
	for index in range(129):
		var t := index/128.0
		for center in [preload("res://scripts/base_approach.gd").point(t),preload("res://scripts/shore_connector.gd").point(t)]:
			var x := clampf(center.x,footprint.position.x,footprint.end.x)
			var z := clampf(center.z,footprint.position.y,footprint.end.y)
			if Vector2(center.x-x,center.z-z).length()<1.8:return true
	return false

func grade_landscape(node: Node) -> void:
	if node is MeshInstance3D:
		var title := str(node.name)
		if title.begins_with("Tree trunk") or title.begins_with("Pine layered crown") or title.begins_with("Scree boulder") or title.begins_with("Trail understory shrub"):
			var bounds: AABB = node.transform*node.get_aabb()
			if intersects_new_route(bounds):
				node.hide()
				for body in node.get_children():
					if body is CollisionObject3D:body.collision_layer=0;body.collision_mask=0
				return
		if title.begins_with("Forested rolling boundary") and node.mesh.get_aabb().position.x>40:
			node.hide()
			return
		if (title.begins_with("Distant forest crown") or title.begins_with("Tree trunk") or title.begins_with("Pine layered crown")) and node.position.x>48:
			node.hide()
			return
	if node is MeshInstance3D and node.name.begins_with("Waste station"):
		node.hide()
		var bin := Node3D.new()
		bin.position = node.position-Vector3(0,.38,0)
		node.get_parent().add_child(bin)
		var visual := (load("res://assets/detailed_waste_bin.glb") as PackedScene).instantiate()
		bin.add_child(visual)
		bin.set_meta("detailed_waste_bin",true)
		var body := StaticBody3D.new()
		body.set_meta("waste_bin_collision",true)
		bin.add_child(body)
		var collider := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = .35
		shape.height = .88
		collider.shape = shape
		collider.position.y = .44
		body.add_child(collider)
		return
	if node is MeshInstance3D and node.name.begins_with("Trail station lettering"):
		node.hide()
		var label := Label3D.new()
		label.text = "МЕСТО ОТДЫХА"
		label.position = node.position+Vector3(0,.04,.025)
		label.font_size = 46
		label.pixel_size = .0027
		label.outline_size = 0
		label.modulate = Color("fff0ce")
		node.get_parent().add_child(label)
		return
	if node is Node3D and node.name.begins_with("Patrol cloud"):
		node.hide()
	if node is MeshInstance3D and node.mesh:
		if node.name.begins_with("Distant forest crown"):
			var bounds: AABB = node.mesh.get_aabb()
			var original: Material = node.get_active_material(0)
			var copy := MeshInstance3D.new()
			copy.mesh = detailed_forest_mesh()
			copy.position = bounds.get_center()
			copy.scale = bounds.size
			if original is StandardMaterial3D:
				retained_cabin_materials.append(original)
				var material := original.duplicate() as StandardMaterial3D
				material.albedo_color *= Color(.64,.64,.64,1)
				retained_cabin_materials.append(material)
				copy.material_override = material
			node.add_child(copy)
			var crown_center: Vector3 = node.global_transform*bounds.get_center()
			var terrain_y := .12*sin(crown_center.x*.12)*sin(-crown_center.z*.08)+maxf(0,(-crown_center.x-15)*.025)*(.5+.5*sin(-crown_center.z*.025))
			var root_local: Vector3 = node.global_transform.affine_inverse()*Vector3(crown_center.x,terrain_y-.1,crown_center.z)
			var trunk_height := maxf(.3,bounds.get_center().y-root_local.y)
			var trunk_mesh := CylinderMesh.new()
			trunk_mesh.height = trunk_height
			trunk_mesh.top_radius = .10
			trunk_mesh.bottom_radius = .18
			var trunk := MeshInstance3D.new()
			trunk.name = "DistantTrunk"
			trunk.mesh = trunk_mesh
			trunk.position = Vector3(bounds.get_center().x,root_local.y+trunk_height*.5,bounds.get_center().z)
			trunk.material_override = mat("67513b")
			node.add_child(trunk)
			node.layers = 0
			return
		if node.name.begins_with("Tall meadow grass clusters") or node.name.begins_with("Grass meadow detail"):
			clear_base_grass(node)
			var grass_material := ShaderMaterial.new()
			grass_material.shader = preload("res://shaders/meadow_grass.gdshader")
			animated_materials.append(grass_material)
			node.material_override = grass_material
		elif node.name.begins_with("Cliff fin") or node.name.begins_with("Trail limestone gallery"):
			if not node.has_meta("rock_collision_checked"):
				node.set_meta("rock_collision_checked",true)
				var has_body := false
				for child in node.get_children():
					if child is StaticBody3D:has_body = true
				if not has_body:node.create_trimesh_collision()
			var rock_material := ShaderMaterial.new()
			rock_material.shader = preload("res://shaders/limestone.gdshader")
			node.material_override = rock_material
		elif node.name.begins_with("Ground") or node.name.begins_with("Forested rolling boundary"):
			var ground_material := ShaderMaterial.new()
			ground_material.shader = preload("res://shaders/meadow_ground.gdshader")
			node.material_override = ground_material
		elif node.name.begins_with("Winding patrol trail") or node.name.begins_with("Scenic loop path"):
			var trail_material := ShaderMaterial.new()
			trail_material.shader = preload("res://shaders/trail_ground.gdshader")
			node.material_override = trail_material
		for index in range(node.mesh.get_surface_count()):
			var original: Material = node.get_active_material(index)
			if original is StandardMaterial3D:
				retained_cabin_materials.append(original)
				var material := original.duplicate() as StandardMaterial3D
				var color := material.albedo_color
				# glTF color constants are linear; tame their bright Compatibility rendering.
				material.albedo_color = Color(color.r*0.64,color.g*0.64,color.b*0.64,color.a)
				node.set_surface_override_material(index,material)
	for child in node.get_children():
		grade_landscape(child)

func grade_cabin(node: Node) -> void:
	if node is Node3D and (node.name.begins_with("Planning board lettering") or node.name.begins_with("Wall planning board")):node.hide()
	var wooden := ["Back wall","Left wall","Door flank","Door header","Window flank","Window sill wall","Window upper wall","Cabin floor","Cabin gable","Work desk top","Equipment shelf","Cabin bench seat","Entry deck plank"]
	if node is MeshInstance3D:
		if node.name.begins_with("Cabin roof") and not node.has_meta("edge_trim_added"):
			node.set_meta("edge_trim_added",true)
			if node.name == "Cabin roof":
				var ridge := MeshInstance3D.new()
				ridge.name = "Continuous roof ridge cap"
				var cap := BoxMesh.new()
				cap.size = Vector3(.28,.16,7.85)
				ridge.mesh = cap
				ridge.position = Vector3(0,4.50,0)
				var cap_material := StandardMaterial3D.new()
				cap_material.albedo_color = Color("515945")
				cap_material.roughness = .9
				ridge.material_override = cap_material
				node.get_parent().add_child(ridge)
			for end in [-1.0,1.0]:
				var trim := MeshInstance3D.new()
				trim.name = "Roof end joint trim front" if end>0 else "Roof end joint trim back"
				var box := BoxMesh.new()
				box.size = Vector3(1.01,1.5,.024)
				trim.mesh = box
				trim.position = Vector3(0,-.6,end*.46)
				var material := StandardMaterial3D.new()
				material.albedo_color = Color("514632")
				material.roughness = .95
				trim.material_override = material
				node.add_child(trim)
		for prefix in wooden:
			if node.name.begins_with(prefix):
				var original: Material = node.get_active_material(0)
				var wood := ShaderMaterial.new()
				wood.shader = preload("res://shaders/cabin_wood.gdshader")
				if original is StandardMaterial3D:
					retained_cabin_materials.append(original)
					wood.set_shader_parameter("wood_color",original.albedo_color)
				node.material_override = wood
				break
	for child in node.get_children():grade_cabin(child)

func add_end_landscape() -> void:
	for end_z in [20.0,-205.0]:
		var vertices := PackedVector3Array()
		var indices := PackedInt32Array()
		var direction := 1.0 if end_z>0 else -1.0
		for row in range(21):
			for col in range(41):
				var x := -100.0+col*5
				var distance := row*5.0
				var height := -.3+minf(distance/20,1.0)*(3.5+2*sin(x*.08)+1.3*cos(distance*.065+x*.04))
				vertices.append(Vector3(x,height,end_z+direction*distance))
		for row in range(20):
			for col in range(40):
				var a := row*41+col
				if direction>0:indices.append_array(PackedInt32Array([a,a+1,a+41,a+1,a+42,a+41]))
				else:indices.append_array(PackedInt32Array([a,a+41,a+1,a+1,a+41,a+42]))
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		for vertex in vertices:surface.add_vertex(vertex)
		for index in indices:surface.add_index(index)
		surface.generate_normals()
		var material := ShaderMaterial.new()
		material.shader = preload("res://shaders/meadow_ground.gdshader")
		part(self,surface.commit(),Vector3.ZERO,material)

func clear_route_tree_groups(landscape: Node3D) -> void:
	for trunk in landscape.get_children():
		if not trunk is MeshInstance3D or not str(trunk.name).begins_with("Tree trunk"):continue
		var pieces: Array[MeshInstance3D] = [trunk]
		for crown in landscape.get_children():
			if crown is MeshInstance3D and str(crown.name).begins_with("Pine layered crown") and Vector2(crown.position.x-trunk.position.x,crown.position.z-trunk.position.z).length()<.8:
				pieces.append(crown)
		var removed := false
		for piece in pieces:
			if not piece.visible:removed=true
		if removed:
			for piece in pieces:
				piece.hide()
				piece.set_meta("route_tree_group_removed",true)
				for body in piece.get_children():
					if body is CollisionObject3D:body.collision_layer=0;body.collision_mask=0

func remove_rock_tree_overlaps(landscape: Node3D) -> void:
	var rocks: Array[AABB] = []
	var trees: Array[MeshInstance3D] = []
	for node in landscape.get_children():
		if not node is MeshInstance3D:continue
		if node.name.begins_with("Cliff fin") or node.name.begins_with("Trail limestone gallery"):
			rocks.append(node.transform*node.mesh.get_aabb())
		elif node.name.begins_with("Tree trunk"):trees.append(node)
	var removed := 0
	for trunk in trees:
		var pieces: Array[MeshInstance3D] = [trunk]
		var footprint: AABB = trunk.transform*trunk.mesh.get_aabb()
		for node in landscape.get_children():
			if node is MeshInstance3D and node.name.begins_with("Pine layered crown"):
				if Vector2(node.position.x-trunk.position.x,node.position.z-trunk.position.z).length()<.8:
					pieces.append(node)
					footprint = footprint.merge(node.transform*node.mesh.get_aabb())
		var overlaps := false
		for rock in rocks:
			if footprint.grow(.25).intersects(rock):overlaps = true
		if overlaps:
			removed+=1
			for piece in pieces:
				piece.hide()
				piece.set_meta("rock_overlap_removed",true)
	landscape.set_meta("trees_removed_from_rocks",removed)

func add_end_forest(landscape: Node3D) -> void:
	var trunk := landscape.get_node_or_null("Tree trunk_001") as MeshInstance3D
	if not trunk:return
	var template: Array[MeshInstance3D] = [trunk]
	for child in landscape.get_children():
		if child is MeshInstance3D and child.name.begins_with("Pine layered crown"):
			if Vector2(child.position.x-trunk.position.x,child.position.z-trunk.position.z).length()<.8:template.append(child)
	var rng := RandomNumberGenerator.new()
	rng.seed = 954
	for end_z in [20.0,-205.0]:
		var direction := 1.0 if end_z>0 else -1.0
		for index in range(65):
			var x := rng.randf_range(-90,90)
			var distance := rng.randf_range(15,85)
			var ground := -.3+minf(distance/20,1.0)*(3.5+2*sin(x*.08)+1.3*cos(distance*.065+x*.04))
			var tree := Node3D.new()
			tree.name = "BackgroundConifer"
			tree.set_meta("background_conifer",true)
			tree.position = Vector3(x,ground-.15,end_z+direction*distance)
			tree.scale = Vector3.ONE*rng.randf_range(.8,1.5)
			add_child(tree)
			for source in template:
				var copy := MeshInstance3D.new()
				copy.mesh = source.mesh
				copy.transform = source.transform
				copy.position -= Vector3(trunk.position.x,0,trunk.position.z)
				for surface in range(source.mesh.get_surface_count()):copy.set_surface_override_material(surface,source.get_active_material(surface))
				tree.add_child(copy)

func _ready() -> void:
	plant_catalog.load_catalog()
	progression.load_progress()
	experience = progression.xp
	var sky := ProceduralSkyMaterial.new()
	sky.sky_top_color = Color("479bcc")
	sky.sky_horizon_color = Color("e8dec3")
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_SKY
	environment.environment.sky = Sky.new()
	environment.environment.sky.sky_material = sky
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("b3d3de")
	environment.environment.ambient_light_energy = 0.3
	environment.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	add_child(environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45,-30,0)
	sun.light_color = Color("ffe7b5")
	sun.light_energy = 0.85
	add_child(sun)
	Settings.apply(Settings.read_values(),get_viewport())
	sun.shadow_enabled = Settings.read_values().shadows
	var location := load("res://assets/patrol_location.glb") as PackedScene
	var landscape := location.instantiate()
	add_child(landscape)
	for rock in landscape.get_children():
		if rock is MeshInstance3D and str(rock.name).begins_with("Cliff fin"):
			rock.transform = Transform3D(Basis(Vector3.UP,PI/2),Vector3(330,1,-95))*rock.transform
			var bounds: AABB = rock.transform*rock.get_aabb()
			var center := bounds.get_center()
			var height_scale := .82+.26*sin(center.z*.11)+.14*sin(center.z*.29)
			var width_scale := 1.0+.32*sin(center.z*.17)
			var variation := Transform3D(Basis.from_scale(Vector3(1.0,height_scale,width_scale)),Vector3.ZERO)
			variation.origin = Vector3(center.x+2.2*sin(center.z*.085),bounds.position.y,center.z+1.8*sin(center.z*.09))-variation.basis*Vector3(center.x,bounds.position.y,center.z)
			rock.transform = variation*rock.transform
	grade_landscape(landscape)
	clear_route_tree_groups(landscape)
	remove_rock_tree_overlaps(landscape)
	var flowers := preload("res://scripts/meadow_flowers.gd").new()
	add_child(flowers)
	flowers.build(self,landscape)
	var approach := preload("res://scripts/base_approach.gd").build()
	add_child(approach)
	approach.create_trimesh_collision()
	var shore_path := preload("res://scripts/shore_connector.gd").build()
	add_child(shore_path)
	shore_path.create_trimesh_collision()
	var forest_loop := preload("res://scripts/exploration_path.gd").build()
	add_child(forest_loop)
	forest_loop.create_trimesh_collision()
	add_end_landscape()
	for rest_z in [-40.0,-95.0,-155.0]:
		# Recessed footing closes the gap under the imported plank platform.
		box(self,Vector3(-6,-.08,rest_z-.8),Vector3(3.92,.55,1.93),"786c50",true)
	add_end_forest(landscape)
	var sky_birds := preload("res://scripts/sky_birds.gd").new()
	add_child(sky_birds)
	add_child(preload("res://scripts/soft_clouds.gd").new())
	var bank := preload("res://scripts/riverbank.gd").build()
	add_child(bank)
	bank.create_trimesh_collision()
	add_child(preload("res://scripts/riverbank.gd").distant_bank())
	var river_plane := PlaneMesh.new()
	river_plane.size = Vector2(60,260)
	river_plane.subdivide_width = 40
	river_plane.subdivide_depth = 80
	var river_mat := ShaderMaterial.new()
	river_mat.shader = load("res://shaders/river.gdshader")
	animated_materials.append(river_mat)
	part(self,river_plane,Vector3(85,-.6,-95),river_mat)
	var cabin := load("res://assets/ranger_base.glb") as PackedScene
	for at in bases:
		var base := cabin.instantiate() as Node3D
		base.position = at
		add_child(base)
		grade_landscape(base)
		grade_cabin(base)
		var lamp := OmniLight3D.new()
		lamp.position = at+Vector3(0,2.5,0)
		lamp.light_color = Color("ffe2a1")
		lamp.light_energy = 2.2
		lamp.omni_range = 9
		lamp.omni_attenuation = .6
		add_child(lamp)
		# Replace the narrow imported board with a backing sized for all three notes.
		box(self,at+Vector3(-1.5,2.12,-3.28),Vector3(3.35,1.42,.06),"94734b")
		var station_label := Label3D.new()
		station_label.text = "СТЕНД КОМАНДЫ"
		station_label.position = at+Vector3(-1.5,2.58,-3.235)
		station_label.font_size = 48
		station_label.outline_size = 2
		station_label.pixel_size = .003
		station_label.modulate = Color("f3e8cb")
		add_child(station_label)
		for index in range(3):
			var x := -2.4+index*.9
			box(self,at+Vector3(x,1.82,-3.23),Vector3(.75,.47,.012),"ece0b7")
			var pin := SphereMesh.new()
			pin.radius = .025
			pin.height = .05
			part(self,pin,at+Vector3(x,2.01,-3.20),mat("bf7157"))
			var memo := Label3D.new()
			memo.text = ["МАРШРУТ\nM — схема","СДАЧА\nE — разгрузить","РАСТЕНИЯ\nНе срывайте"][index]
			memo.position = at+Vector3(x,1.81,-3.215)
			memo.font_size = 30
			memo.pixel_size = .0025
			memo.outline_size = 0
			memo.modulate = Color("354c3e")
			add_child(memo)
		box(self,at+Vector3(2.8,.72,6.2),Vector3(.10,1.44,.10),"624b30")
		box(self,at+Vector3(2.8,1.48,6.2),Vector3(1.45,.40,.10),"bd9b65")
		var ramp := box(self,at+Vector3(0,.08,8.04),Vector3(4.0,.08,1.35),"94754c")
		ramp.rotation.x = atan(.17/1.35)
		ramp.create_trimesh_collision()
		ramp.set_meta("delivery_ramp",true)
		var base_sign := Label3D.new()
		base_sign.text = "СДАЧА"
		base_sign.position = at+Vector3(2.8,1.48,6.26)
		base_sign.font_size = 48
		base_sign.pixel_size = .003
		base_sign.outline_size = 0
		base_sign.modulate = Color("30271c")
		add_child(base_sign)
	add_route_sign(Vector3(3.8,0,-60))
	add_route_sign(Vector3(24,.02,-138),true)
	# Collision-only safety perimeter stays behind landscape and riverbank.
	for entry in [[Vector3(-49,4,-95),Vector3(1,12,250)],[Vector3(55.5,4,-95),Vector3(1,12,250)],[Vector3(2,4,24),Vector3(104,12,1)],[Vector3(2,4,-210),Vector3(104,12,1)]]:
		var boundary := StaticBody3D.new()
		boundary.name = "LandscapeBoundary"
		boundary.position = entry[0]
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = entry[1]
		collision.shape = shape
		boundary.add_child(collision)
		add_child(boundary)
	outline_material = ShaderMaterial.new()
	outline_material.shader = load("res://shaders/interactable_outline.gdshader")
	for i in range(8):
		var item := Node3D.new()
		var distance := 12.0+i*18.0
		item.position = Vector3(2.5*sin(distance*.035)+(-1 if i%2==0 else 1)*1.25,.28,-distance)
		add_child(item)
		var prop_paths := ["res://assets/litter_bottle.glb","res://assets/litter_can.glb","res://assets/litter_cup.glb"]
		item.set_meta("title",["Пластиковая бутылка","Смятая банка","Бумажный стакан"][i%3])
		var visual := (load(prop_paths[i%3]) as PackedScene).instantiate()
		item.add_child(visual)
		grade_landscape(visual)
		var body := StaticBody3D.new()
		body.set_meta("pickup",item)
		item.add_child(body)
		var collider := CollisionShape3D.new()
		var pickup_shape := SphereShape3D.new()
		pickup_shape.radius = .27
		collider.shape = pickup_shape
		body.add_child(collider)
		visual.set_meta("outline",true)
		item.rotation.z = 1.2
		item.position.y = .12
		rubbish.append(item)
	cart = CharacterBody3D.new()
	cart.floor_snap_length = .4
	cart.floor_constant_speed = true
	cart.position = Vector3(1,0,4)
	add_child(cart)
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = .55
	shape.height = 1.5
	collision.shape = shape
	collision.rotation.x = PI/2
	collision.position.y = .55
	cart.add_child(collision)
	for plank in range(6):
		box(cart,Vector3(-.46+plank*.185,.6,0),Vector3(.175,.12,1.5),"94754c" if plank%2==0 else "a58558")
	for x in [-.55,.55]:
		for level in range(3):
			box(cart,Vector3(x,.76+level*.19,0),Vector3(.075,.17,1.5),"b7955d" if level%2==0 else "a58558")
		for z in [-.62,.62]:
			box(cart,Vector3(x*1.04,.94,z),Vector3(.055,.65,.075),"394b43")
			for height in [.76,.95,1.14]:
				var rivet := SphereMesh.new()
				rivet.radius = .018
				rivet.height = .036
				part(cart,rivet,Vector3(x*1.1,height,z),mat("b1aa86"))
		var wheel := CylinderMesh.new()
		wheel.height = .13
		wheel.top_radius = .32
		wheel.bottom_radius = .32
		var w := part(cart,wheel,Vector3(x,.32,0),mat("303934"))
		w.rotation.z = PI/2
		wheels.append(w)
		var rim := CylinderMesh.new()
		rim.height = .14
		rim.top_radius = .24
		rim.bottom_radius = .24
		part(w,rim,Vector3.ZERO,mat("8b937d"))
		var hub := CylinderMesh.new()
		hub.height = .19
		hub.top_radius = .065
		hub.bottom_radius = .065
		part(w,hub,Vector3.ZERO,mat("394b43"))
	for level in range(3):
		box(cart,Vector3(0,.76+level*.19,-.7),Vector3(1.1,.17,.075),"b7955d")
	for x in [-.46,.46]:
		box(cart,Vector3(x,.85,.85),Vector3(.07,.07,.85),"394b43")
	box(cart,Vector3(0,.85,1.15),Vector3(1.05,.08,.08),"394b43")
	player = CharacterBody3D.new()
	player.set_script(PlayerScript)
	player.position = Vector3(0,.3,8)
	add_child(player)
	var layer := CanvasLayer.new()
	add_child(layer)
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(ui)
	hud = Control.new()
	hud.set_script(preload("res://scripts/patrol_hud.gd"))
	ui.add_child(hud)
	prompt = hud.prompt_label
	message = hud.notice_label
	notify("Первый обход: соберите 8 предметов и доставьте их на базу.")
	preload("res://scripts/plant_placements.gd").new().spawn(self,plant_catalog)
	call_deferred("ground_spawned_items")

func ground_spawned_items() -> void:
	for item in rubbish:
		var query := PhysicsRayQueryParameters3D.create(item.position+Vector3(0,3,0),item.position-Vector3(0,3,0))
		var excluded: Array[RID] = []
		for child in item.get_children():
			if child is CollisionObject3D:excluded.append(child.get_rid())
		query.exclude = excluded
		var hit := get_world_3d().direct_space_state.intersect_ray(query)
		if not hit.is_empty():
			item.position.y += hit.position.y-lowest_mesh_y(item,item.position.y)+.008

func add_route_sign(at: Vector3, riverside: bool = false) -> void:
	var root := Node3D.new()
	root.name = "ForkRouteSign"
	root.position = at
	add_child(root)
	box(root,Vector3(0,.95,-.10),Vector3(.12,1.9,.12),"6c5538",true)
	for row in range(2):
		var height := 1.7-row*.40
		box(root,Vector3(0,height,0),Vector3(2.8,.34,.10),"81633f")
		var label := Label3D.new()
		if riverside:
			label.text = "↑  БАЗА · СДАЧА МУСОРА" if row==0 else "→  БЕРЕГ · ОБЗОР СТОЛБОВ"
		else:
			label.text = "↑  БАЗА · ОСНОВНАЯ ТРОПА" if row==0 else "←  ЛЕСНАЯ ПРОГУЛОЧНАЯ ПЕТЛЯ"
		label.position = Vector3(0,height,.058)
		label.font_size = 64
		label.outline_size = 2
		label.pixel_size = .0025
		label.modulate = Color("f3e8cb")
		root.add_child(label)
	box(root,Vector3(0,1.0,0),Vector3(1.6,.22,.10),"81633f")
	var caution := Label3D.new()
	caution.text = "Оставайтесь на тропе"
	caution.position = Vector3(0,1.0,.065)
	caution.font_size = 24
	caution.pixel_size = .003
	root.add_child(caution)

func navigation_destination() -> Vector3:
	if cargo<=0:return delivery_points[1]
	var nearest: Vector3 = delivery_points[0]
	for point in delivery_points:
		if player.position.distance_squared_to(point)<player.position.distance_squared_to(nearest):nearest = point
	return nearest

func recover_cart() -> void:
	cart.position = Vector3(1,.2,4)
	cart.velocity = Vector3.ZERO
	last_player_position = player.position

func notify(text: String) -> void:
	message.text = text
	message_timer = 6

func update_effect_time(delta: float) -> void:
	if is_patrol_paused():return
	effect_time += delta
	for material in animated_materials:material.set_shader_parameter("patrol_time",effect_time)

func _process(delta: float) -> void:
	update_effect_time(delta)
	hud.visible = not is_instance_valid(overlay) or overlay.is_queued_for_deletion()
	if is_instance_valid(overlay):preload("res://scripts/ui_theme.gd").skin_buttons(overlay)
	cloud_time += delta
	for index in range(moving_clouds.size()):
		moving_clouds[index].position = cloud_origins[index]+Vector3(12*sin(cloud_time*.01),0,0)
	message_timer -= delta
	if message_timer<=0:
		message.text = ""
	hud.update_values(player.health,player.stamina,cargo,progression.capacity(),delivered,experience)
	hud.update_inventory(held_item,inventory)
	var to_base: Vector3 = navigation_destination()-player.position
	var forward := -player.transform.basis.z
	var angle := forward.signed_angle_to(to_base.normalized(),Vector3.UP)
	var direction := "↑" if absf(angle)<0.55 else ("↓" if absf(angle)>2.5 else ("←" if angle>0 else "→"))
	hud.navigation_label.text = "%s  %s · %d м" % [direction,"СДАЧА" if cargo>0 else "БАЗА",to_base.length()]
	hud.compass.heading = -player.rotation.y
	hud.compass.target_angle = -angle
	hud.compass.distance = int(to_base.length())
	hud.compass.queue_redraw()
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		settings_refresh_timer -= delta
		if settings_refresh_timer<=0:
			settings_refresh_timer = .15
			player.settings = Settings.read_values()
			player.camera.fov = player.settings.fov
			sun.shadow_enabled = player.settings.shadows
		return
	prompt.text = ""
	if player.position.distance_to(cart.position)<3:
		prompt.text = "E — отпустить тележку" if player.dragging else "E — взять тележку"
	update_focus()
	if held_item:
		prompt.text = "E · загрузить\nR · убрать  G · положить"
	elif is_instance_valid(focused_item):
		prompt.text = "E — взять предмет в руки"
	elif not focused_species.is_empty():
		prompt.text = "E — изучить растение, не срывая"
	if near_delivery().x<999 and cargo>0:
		prompt.text = "E — сдать груз на базе"
	if at_upgrade_station():
		prompt.text = "E — стенд улучшений команды"

func set_outline(node: Node, enabled: bool) -> void:
	if node is MeshInstance3D:
		node.material_overlay = outline_material if enabled else null
	for child in node.get_children():set_outline(child,enabled)

func update_focus() -> void:
	var start: Vector3 = player.camera.global_position
	var end: Vector3 = start-player.camera.global_transform.basis.z*3.2
	var query := PhysicsRayQueryParameters3D.create(start,end)
	query.exclude = [player.get_rid(),cart.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	var next_item: Node3D = null
	var next_plant: Node3D = null
	focused_species = ""
	if not hit.is_empty() and hit.collider.has_meta("species_id"):
		var id := str(hit.collider.get_meta("species_id"))
		if not plant_catalog.find_species(id).is_empty():
			focused_species = id
			next_plant = hit.collider.get_meta("plant_visual",null)
	if focused_plant!=next_plant:
		if is_instance_valid(focused_plant):set_outline(focused_plant,false)
		focused_plant = next_plant
		if is_instance_valid(focused_plant):set_outline(focused_plant,true)
	if not hit.is_empty() and hit.collider.has_meta("pickup"):
		next_item = hit.collider.get_meta("pickup")
	if focused_item!=next_item:
		if is_instance_valid(focused_item):set_outline(focused_item,false)
		focused_item = next_item
		if is_instance_valid(focused_item):set_outline(focused_item,true)

func place_in_hand(item: Node3D) -> void:
	item.reparent(player.camera)
	item.position = Vector3(.22,-.25,-.82)
	item.rotation = Vector3(0,0,.35)
	if str(item.get_meta("title","")).contains("банка"):
		item.position += Vector3(-.015,.035,-.025)
	item.show()

func pickup(item: Node3D) -> void:
	if held_item or player.dragging:
		notify("Освободите руки перед подбором предмета.")
		return
	rubbish.erase(item)
	set_outline(item,false)
	for child in item.get_children():
		if child is StaticBody3D:
			child.collision_layer = 0
			child.collision_mask = 0
		if child is MeshInstance3D: child.material_overlay = null
	place_in_hand(item)
	held_item = item
	focused_item = null

func select_hotbar(index: int) -> void:
	if player.dragging or index<0 or index>=inventory.size():return
	var selected: Node3D = inventory[index]
	if held_item:
		var previous := held_item
		previous.reparent(self)
		previous.hide()
		inventory[index] = previous
	else:inventory.remove_at(index)
	held_item = selected
	place_in_hand(selected)

func stow_or_retrieve() -> void:
	if held_item:
		if inventory.size()>=INVENTORY_CAPACITY:
			notify("Рюкзак заполнен: 3 предмета.")
			return
		held_item.reparent(self)
		held_item.hide()
		inventory.append(held_item)
		held_item = null
	elif not inventory.is_empty() and not player.dragging:
		held_item = inventory.pop_back()
		place_in_hand(held_item)

func lowest_mesh_y(node: Node3D, fallback: float) -> float:
	var lowest := fallback
	if node is MeshInstance3D and node.mesh:
		var bounds: AABB = node.mesh.get_aabb()
		for x in [bounds.position.x,bounds.end.x]:
			for y in [bounds.position.y,bounds.end.y]:
				for z in [bounds.position.z,bounds.end.z]:
					lowest = minf(lowest,(node.global_transform*Vector3(x,y,z)).y)
	for child in node.get_children():
		if child is Node3D:lowest = minf(lowest,lowest_mesh_y(child,lowest))
	return lowest

func highest_mesh_y(node: Node3D, fallback: float) -> float:
	var highest := fallback
	if node is MeshInstance3D and node.mesh:
		var bounds: AABB = node.mesh.get_aabb()
		for x in [bounds.position.x,bounds.end.x]:
			for y in [bounds.position.y,bounds.end.y]:
				for z in [bounds.position.z,bounds.end.z]:
					highest = maxf(highest,(node.global_transform*Vector3(x,y,z)).y)
	for child in node.get_children():
		if child is Node3D:highest = maxf(highest,highest_mesh_y(child,highest))
	return highest

func drop_held() -> void:
	if not held_item: return
	var at := player.position-player.transform.basis.z*1.1
	var query := PhysicsRayQueryParameters3D.create(at+Vector3(0,2,0),at-Vector3(0,3,0))
	query.exclude = [player.get_rid(),cart.get_rid()]
	var ground := get_world_3d().direct_space_state.intersect_ray(query)
	if ground.is_empty() or ground.normal.y<.65:
		notify("Выберите ровную поверхность перед собой.")
		return
	if ground.position.x < -47 or ground.position.x > 51 or ground.position.z < -208 or ground.position.z > 22:
		notify("Предмет нельзя оставлять за границей маршрута.")
		return
	var clearance := PhysicsShapeQueryParameters3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = .16
	clearance.shape = sphere
	clearance.transform = Transform3D(Basis.IDENTITY,ground.position+Vector3(0,.22,0))
	clearance.exclude = [player.get_rid(),cart.get_rid()]
	clearance.collision_mask = 1
	if not get_world_3d().direct_space_state.intersect_shape(clearance,1).is_empty():
		notify("Здесь недостаточно места. Отойдите от стены или предметов.")
		return
	held_item.reparent(self)
	held_item.global_position = ground.position
	held_item.rotation = Vector3(0,0,1.2)
	var lowest := lowest_mesh_y(held_item,ground.position.y)
	held_item.position.y += ground.position.y-lowest+.008
	for child in held_item.get_children():
		if child is StaticBody3D:
			child.collision_layer = 1
			child.collision_mask = 1
	rubbish.append(held_item)
	held_item = null

func _physics_process(delta: float) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		last_player_position = player.position
		return
	session_seconds += delta
	var step_distance := player.position.distance_to(last_player_position)
	if step_distance<2:walked_distance += step_distance
	last_player_position = player.position
	var cart_before := cart.position
	if player.dragging:
		var target := player.position-player.transform.basis.z*2
		var difference := target-cart.position
		cart.velocity = Vector3(difference.x*4,-3,difference.z*4)
		cart.move_and_slide()
		cart.rotation.y = lerp_angle(cart.rotation.y,player.rotation.y,delta*4)
		if cart.position.distance_to(player.position)>4:
			player.dragging = false
			notify("Тележка застряла. Подойдите и выберите свободный путь.")
	else:
		cart.velocity.x = move_toward(cart.velocity.x,0,delta*12)
		cart.velocity.z = move_toward(cart.velocity.z,0,delta*12)
		cart.velocity.y -= delta*18
		cart.move_and_slide()
	var travel := cart.position-cart_before
	travel.y = 0
	var rolling := travel.dot(-cart.transform.basis.z)/.32
	for wheel in wheels:wheel.rotate_y(rolling)
	if cart.position.y < -4 or cart.position.x < -50 or cart.position.x > 54 or cart.position.z > 25 or cart.position.z < -211:
		cart.position = Vector3(1,.3,4)
		cart.velocity = Vector3.ZERO
		player.dragging = false
		notify("Тележку вернули к базе после падения.")

func pause_on_focus_loss() -> void:
	if not is_instance_valid(player) or not is_instance_valid(ui):return
	if is_instance_valid(overlay) and not overlay.is_queued_for_deletion():return
	if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:pause_menu(false)

func _notification(what: int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT:pause_on_focus_loss()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_ESCAPE:
			if is_instance_valid(overlay):
				overlay.queue_free()
				resume()
				return
			pause_menu(false)
		elif event.keycode==KEY_TAB and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			pause_menu(true)
		elif event.keycode==KEY_M and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			map_menu()
		elif event.keycode==KEY_I and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			inventory_menu()
		elif event.keycode in [KEY_1,KEY_2,KEY_3] and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			select_hotbar(int(event.keycode)-int(KEY_1))
		elif event.keycode==KEY_R and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			stow_or_retrieve()
		elif event.keycode==KEY_G and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			drop_held()
		elif event.keycode==KEY_E and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			interact()

func cargo_pose(slot: int) -> Transform3D:
	var column := slot%2
	var row := (slot/2)%3
	var tier := slot/6
	return Transform3D(Basis.from_euler(Vector3(0,(slot%3)*.45,PI/2)),Vector3(-.25+column*.5,.8+tier*.28,-.46+row*.46))

func interact() -> void:
	if not focused_species.is_empty():
		var record: Dictionary = plant_catalog.find_species(focused_species)
		if not record.is_empty():
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			overlay = preload("res://scripts/plant_card.gd").make_panel(ui,record,resume)
			observed_species[focused_species] = true
		return
	if at_upgrade_station():
		pause_menu(true)
		return
	var delivery := near_delivery()
	if delivery.x<999 and cargo>0:
		if cart.position.distance_to(delivery)>4:
			notify("Подвезите тележку с грузом к площадке базы.")
			return
		if progression.award(cargo*25)!=OK:
			notify("Не удалось сохранить опыт. Груз сохранён в тележке — попробуйте снова.")
			return
		delivered += cargo
		session_xp += cargo*25
		experience = progression.xp
		cargo = 0
		for child in cart.get_children():
			if child.name.begins_with("Cargo"):
				retain_visual_materials(child)
				child.queue_free()
		notify("Обход завершён! Доставлено 8 предметов. Получено 200 опыта." if delivered>=8 else "Груз принят. Продолжайте обход.")
		if delivered>=8 and not results_shown:
			results_shown = true
			call_deferred("show_results")
		return
	if held_item and player.position.distance_to(cart.position)<3:
		if cargo>=progression.capacity():
			notify("Тележка заполнена.")
			return
		cargo+=1
		collected+=1
		held_item.reparent(cart)
		held_item.transform = cargo_pose(cargo-1)
		var support_height := cart.global_position.y+.67
		if cargo>6:
			for child in cart.get_children():
				if child is Node3D and child.get_meta("cargo_slot",-1)==cargo-7:
					support_height = highest_mesh_y(child,support_height)
		held_item.set_meta("cargo_slot",cargo-1)
		var bottom := lowest_mesh_y(held_item,INF)
		if is_finite(bottom):held_item.position.y += support_height-bottom
		held_item.name = "Cargo%d" % collected
		held_item = null
		return
	if is_instance_valid(focused_item):
		pickup(focused_item)
		return
	if player.position.distance_to(cart.position)<3 and not held_item:
		player.dragging = not player.dragging

func retain_visual_materials(node: Node) -> void:
	if node is MeshInstance3D:
		if node.material_override:retained_cabin_materials.append(node.material_override)
		if node.material_overlay:retained_cabin_materials.append(node.material_overlay)
		for surface in range(node.mesh.get_surface_count()):
			var material: Material = node.get_active_material(surface)
			if material:retained_cabin_materials.append(material)
	for child in node.get_children():retain_visual_materials(child)

func show_results() -> void:
	if is_instance_valid(overlay):return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	overlay = PanelContainer.new()
	overlay.theme = preload("res://scripts/ui_theme.gd").make_theme()
	overlay.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel_style())
	ui.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",28)
	overlay.add_child(column)
	var title := Label.new()
	title.text = "ПЕРВЫЙ ОБХОД ЗАВЕРШЁН"
	title.add_theme_font_size_override("font_size",32)
	column.add_child(title)
	var summary := Label.new()
	summary.add_theme_font_size_override("font_size",24)
	summary.size_flags_vertical = Control.SIZE_EXPAND_FILL
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.text = "Доставлено мусора: %d / 8\nОпыт за обход: %d\nВремя на тропе: %d мин %02d с\nПройдено: %d м" % [delivered,session_xp,int(session_seconds)/60,int(session_seconds)%60,walked_distance]
	summary.text += "\nИзучено видов: %d / %d" % [observed_species.size(),plant_catalog.entries.size()] if not plant_catalog.entries.is_empty() else "\nГербарий: подтверждённые материалы ещё не подключены."
	column.add_child(summary)
	var fact := Label.new()
	fact.text = "Оставайтесь на оборудованной тропе.\nИзучайте растения, не срывая их, и забирайте мусор с собой."
	fact.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(fact)
	var close := Button.new()
	close.text = "Продолжить прогулку"
	close.custom_minimum_size.y = 48
	column.add_child(close)
	close.pressed.connect(func() -> void:
		overlay.queue_free()
		resume())
	preload("res://scripts/ui_theme.gd").skin_buttons(overlay)

func map_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	overlay = PanelContainer.new()
	overlay.theme = preload("res://scripts/ui_theme.gd").make_theme()
	var map_style := preload("res://scripts/ui_theme.gd").panel_style()
	map_style.bg_color = Color("302c23")
	overlay.add_theme_stylebox_override("panel",map_style)
	ui.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.custom_minimum_size = Vector2(1280,720)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",12)
	overlay.add_child(column)
	var title := Label.new()
	title.text = "КАРТА ОБХОДА"
	title.add_theme_font_size_override("font_size",24)
	column.add_child(title)
	var disclaimer := Label.new()
	disclaimer.text = "Игровая схема · Домик — база · Круг — вы · Тележка — груз\nНе является реальной туристической картой парка"
	column.add_child(disclaimer)
	var map := preload("res://scripts/route_map.gd").new()
	map.player_position = player.position
	map.cart_position = cart.position
	map.bases = bases
	map.custom_minimum_size = Vector2(1100,480)
	map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(map)
	var close := Button.new()
	close.text = "Вернуться на тропу"
	close.custom_minimum_size.y = 44
	column.add_child(close)
	close.pressed.connect(func() -> void:
		overlay.queue_free()
		resume())

func inventory_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	overlay = PanelContainer.new()
	overlay.theme = preload("res://scripts/ui_theme.gd").make_theme()
	ui.add_child(overlay)
	overlay.position = Vector2.ZERO
	overlay.custom_minimum_size = Vector2(1280,720)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("302c23")
	panel_style.set_corner_radius_all(16)
	panel_style.set_content_margin_all(24)
	panel_style.set_border_width_all(1)
	panel_style.border_color = Color("b7a16e")
	overlay.add_theme_stylebox_override("panel",panel_style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",14)
	overlay.add_child(column)
	var title := Label.new()
	title.text = "РЮКЗАК · %d / %d" % [inventory.size(),INVENTORY_CAPACITY]
	title.add_theme_font_size_override("font_size",24)
	column.add_child(title)
	var hand := Label.new()
	hand.text = "В руках: %s" % held_item.get_meta("title","Предмет") if held_item else "Руки свободны"
	column.add_child(hand)
	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation",24)
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(cards)
	for index in range(INVENTORY_CAPACITY):
		var item: Node3D = inventory[index] if index<inventory.size() else null
		var card := VBoxContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cards.add_child(card)
		var icon := preload("res://scripts/item_icon.gd").new()
		icon.title = str(item.get_meta("title","Предмет")) if item else ""
		icon.custom_minimum_size = Vector2(60,48)
		icon.scale = Vector2(3,3)
		var frame := Control.new()
		frame.custom_minimum_size.y = 190
		card.add_child(frame)
		frame.add_child(icon)
		icon.position = Vector2(60,20)
		var button := Button.new()
		button.text = str(item.get_meta("title","Предмет")) if item else "Пустой слот"
		button.custom_minimum_size.y = 80
		button.disabled = item==null or held_item!=null or player.dragging
		card.add_child(button)
		button.pressed.connect(func() -> void:
			if not is_instance_valid(item) or held_item or player.dragging:return
			inventory.erase(item)
			held_item = item
			place_in_hand(item)
			overlay.queue_free()
			resume())
	var close := Button.new()
	close.text = "Вернуться"
	close.custom_minimum_size.y = 48
	column.add_child(close)
	close.pressed.connect(func() -> void:
		overlay.queue_free()
		resume())

func at_upgrade_station() -> bool:
	for at in bases:
		if player.position.distance_to(at+Vector3(-2,0,-1.5))<2.3:
			var query := PhysicsRayQueryParameters3D.create(player.camera.global_position,at+Vector3(-2,1.65,-1.5),1)
			query.exclude = [player.get_rid(),cart.get_rid()]
			if get_world_3d().direct_space_state.intersect_ray(query).is_empty():return true
	return false

func rest_at_base() -> bool:
	if not at_upgrade_station():return false
	player.health = 100
	player.stamina = 100
	player.sprint_exhausted = false
	player.last_fall = 0
	notify("Отдых на базе: здоровье и силы восстановлены.")
	return true

func skill_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	overlay = PanelContainer.new()
	overlay.theme = preload("res://scripts/ui_theme.gd").make_theme()
	var style := preload("res://scripts/ui_theme.gd").panel_style()
	style.bg_color = Color("302c23")
	overlay.add_theme_stylebox_override("panel",style)
	ui.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := VBoxContainer.new()
	overlay.add_child(column)
	var tree := preload("res://scripts/skill_tree.gd").new()
	tree.world = self
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(tree)
	var actions := HBoxContainer.new()
	column.add_child(actions)
	var journal := Button.new()
	journal.text = "Журнал"
	journal.custom_minimum_size = Vector2(240,50)
	actions.add_child(journal)
	journal.pressed.connect(func():
		overlay.queue_free()
		journal_menu())
	if at_upgrade_station():
		var rest := Button.new()
		rest.text = "Отдых"
		rest.custom_minimum_size = Vector2(240,50)
		rest.disabled = player.health>=100 and player.stamina>=100
		actions.add_child(rest)
		rest.pressed.connect(func():
			if rest_at_base():
				overlay.queue_free()
				resume())
	var close := Button.new()
	close.text = "Вернуться на тропу"
	close.custom_minimum_size.y = 50
	close.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(close)
	close.pressed.connect(func():
		overlay.queue_free()
		resume())

func journal_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	overlay = PanelContainer.new()
	overlay.theme = preload("res://scripts/ui_theme.gd").make_theme()
	var style := preload("res://scripts/ui_theme.gd").panel_style()
	style.bg_color = Color("302c23")
	overlay.add_theme_stylebox_override("panel",style)
	ui.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := VBoxContainer.new()
	overlay.add_child(column)
	var title := Label.new()
	title.text = "ЖУРНАЛ ОБХОДА"
	title.add_theme_font_size_override("font_size",28)
	column.add_child(title)
	var progress := Label.new()
	progress.text = "Очистить маршрут · %d / 8 доставлено" % delivered
	column.add_child(progress)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var records := VBoxContainer.new()
	records.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(records)
	var status := Label.new()
	status.text = "Гербарий · %d / %d изучено" % [observed_species.size(),plant_catalog.entries.size()] if not plant_catalog.entries.is_empty() else "Гербарий ожидает подтверждённые материалы к ТЗ."
	records.add_child(status)
	for entry in plant_catalog.entries:
		if not observed_species.has(entry.get("id","")):continue
		var record := Button.new()
		record.text = str(entry.get("name_ru",entry.get("id","")))
		record.custom_minimum_size.y = 54
		records.add_child(record)
		record.pressed.connect(func():
			overlay.queue_free()
			overlay = preload("res://scripts/plant_card.gd").make_panel(ui,entry,journal_menu))
	var back := Button.new()
	back.text = "К навыкам"
	back.custom_minimum_size.y = 50
	column.add_child(back)
	back.pressed.connect(func():
		overlay.queue_free()
		skill_menu())

func pause_menu(journal: bool) -> void:
	if journal:
		skill_menu()
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	overlay = PanelContainer.new()
	overlay.theme = preload("res://scripts/ui_theme.gd").make_theme()
	overlay.position = Vector2.ZERO
	overlay.custom_minimum_size = Vector2(1280,720)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("302c23")
	panel_style.set_corner_radius_all(16)
	panel_style.set_content_margin_all(24)
	panel_style.set_border_width_all(1)
	panel_style.border_color = Color("b7a16e")
	overlay.add_theme_stylebox_override("panel",panel_style)
	ui.add_child(overlay)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",8)
	overlay.add_child(column)
	var text := Label.new()
	text.text = "ПАУЗА"
	text.add_theme_font_size_override("font_size",32)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var top_space := Control.new()
	top_space.custom_minimum_size.y = 130
	column.add_child(top_space)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(text)
	for caption in ["Продолжить", "Настройки", "Главное меню"]:
		var b := Button.new()
		b.text = caption
		b.custom_minimum_size = Vector2(420,65)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		column.add_child(b)
		b.pressed.connect(func() -> void:
			if caption=="Главное меню":
				confirm_leave_patrol()
			elif caption=="Настройки":
				overlay.queue_free()
				overlay = Settings.make_panel(ui,resume)
			else:
				overlay.queue_free()
				resume())

func confirm_leave_patrol() -> void:
	if is_instance_valid(overlay):overlay.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	overlay = PanelContainer.new()
	overlay.theme = preload("res://scripts/ui_theme.gd").make_theme()
	overlay.add_theme_stylebox_override("panel",preload("res://scripts/ui_theme.gd").panel_style())
	overlay.position = Vector2(340,230)
	overlay.custom_minimum_size = Vector2(600,230)
	ui.add_child(overlay)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",14)
	overlay.add_child(column)
	var title := Label.new()
	title.text = "ЗАВЕРШИТЬ ТЕКУЩИЙ ОБХОД?"
	title.add_theme_font_size_override("font_size",22)
	column.add_child(title)
	var warning := Label.new()
	warning.text = "Опыт и улучшения сохранены.\nТекущий обход, груз тележки и вещи в рюкзаке не сохраняются."
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(warning)
	for caption in ["Остаться на тропе","Выйти в главное меню"]:
		var button := Button.new()
		button.text = caption
		button.custom_minimum_size.y = 48
		column.add_child(button)
		button.pressed.connect(func() -> void:
			if caption=="Остаться на тропе":
				overlay.queue_free()
				resume()
			else:get_tree().change_scene_to_file("res://scenes/bootstrap.tscn"))

func resume() -> void:
	hud.show()
	player.settings = Settings.read_values()
	player.camera.fov = player.settings.fov
	sun.shadow_enabled = player.settings.shadows
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
