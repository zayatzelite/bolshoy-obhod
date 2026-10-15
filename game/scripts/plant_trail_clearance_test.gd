extends SceneTree

const Placement = preload("res://scripts/plant_placements.gd")
var trails: Array = []
var ground: Array = []

func triangles(node: Node3D) -> Array:
	var result: Array = []
	if node is MeshInstance3D and node.mesh:
		for surface in range(node.mesh.get_surface_count()):
			var arrays: Array = node.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX]!=null else PackedInt32Array()
			if indices.is_empty():
				for i in vertices.size():indices.append(i)
			for i in range(0,indices.size(),3):
				var face: Array = []
				for j in 3:face.append(node.global_transform*vertices[indices[i+j]])
				result.append(face)
	return result

func xz(p: Vector3) -> Vector2:
	return Vector2(p.x,p.z)

func segment_distance(a: Vector2,b: Vector2,c: Vector2,d: Vector2) -> float:
	if Geometry2D.segment_intersects_segment(a,b,c,d)!=null:return 0.0
	return minf(minf(a.distance_to(Geometry2D.get_closest_point_to_segment(a,c,d)),b.distance_to(Geometry2D.get_closest_point_to_segment(b,c,d))),minf(c.distance_to(Geometry2D.get_closest_point_to_segment(c,a,b)),d.distance_to(Geometry2D.get_closest_point_to_segment(d,a,b))))

# Exact XZ distance of a conservative transformed model AABB to every trail triangle.
func clearance(box: AABB) -> float:
	var rect := Rect2(xz(box.position),Vector2(box.size.x,box.size.z))
	var corners: Array[Vector2] = [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]
	var nearest := INF
	for face in trails:
		var a: Vector2=xz(face[0]);var b: Vector2=xz(face[1]);var c: Vector2=xz(face[2])
		var tri: Array[Vector2]=[a,b,c]
		for p in tri:
			if rect.has_point(p):return 0.0
		for p in corners:
			if absf((b-a).cross(c-a))>.000001 and Geometry2D.is_point_in_polygon(p,PackedVector2Array(tri)):return 0.0
		for i in 3:
			for j in 4:nearest=minf(nearest,segment_distance(tri[i],tri[(i+1)%3],corners[j],corners[(j+1)%4]))
	return nearest

# Construct a real point on a trail triangle, not an assumed centreline.
# Test the 3.2m interaction range against the actual (padded) plant hitbox.
func reachable_from_trail(box: AABB) -> float:
	var target:=xz(box.get_center())
	var best:=INF
	for face in trails:
		var tri: Array[Vector2]=[xz(face[0]),xz(face[1]),xz(face[2])]
		if absf((tri[1]-tri[0]).cross(tri[2]-tri[0]))<.000001:continue
		var centroid: Vector2=(tri[0]+tri[1]+tri[2])/3.0
		for i in 3:
			var edge_point:=Geometry2D.get_closest_point_to_segment(target,tri[i],tri[(i+1)%3])
			# Move into the actual triangle; convexity guarantees this remains on the path.
			var witness:=edge_point.lerp(centroid,minf(1.0,.45/maxf(.00001,edge_point.distance_to(centroid))))
			var area: float=(tri[1]-tri[0]).cross(tri[2]-tri[0])
			var u: float=(witness-tri[0]).cross(tri[2]-tri[0])/area
			var v: float=(tri[1]-tri[0]).cross(witness-tri[0])/area
			var y: float=face[0].y+u*(face[1].y-face[0].y)+1.7
			var eye:=Vector3(witness.x,y,witness.y)
			var hitbox:=box.grow(.06)
			var nearest:=Vector3(clampf(eye.x,hitbox.position.x,hitbox.end.x),clampf(eye.y,hitbox.position.y,hitbox.end.y),clampf(eye.z,hitbox.position.z,hitbox.end.z))
			best=minf(best,eye.distance_to(nearest))
	return best

func terrain_height(p: Vector2) -> float:
	for face in ground:
		var a: Vector2=xz(face[0]);var b: Vector2=xz(face[1]);var c: Vector2=xz(face[2])
		var area: float=(b-a).cross(c-a)
		if absf(area)<.000001:continue
		var u: float=(p-a).cross(c-a)/area
		var v: float=(b-a).cross(p-a)/area
		if u>=-.00001 and v>=-.00001 and u+v<=1.00001:return face[0].y+u*(face[1].y-face[0].y)+v*(face[2].y-face[0].y)
	return NAN

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var landscape: Node3D=(load("res://assets/patrol_location.glb") as PackedScene).instantiate()
	root.add_child(landscape)
	for node in landscape.find_children("*","MeshInstance3D",true,false):
		if str(node.name).begins_with("Winding patrol trail") or str(node.name).begins_with("Scenic loop path"):
			var faces:=triangles(node)
			print("TRAIL ",node.name," triangles=",faces.size()," bounds=",node.global_transform*node.get_aabb())
			trails.append_array(faces)
		elif str(node.name).begins_with("Ground"):ground.append_array(triangles(node))
	for script in ["res://scripts/exploration_path.gd","res://scripts/base_approach.gd","res://scripts/shore_connector.gd"]:
		var path: MeshInstance3D=load(script).build()
		root.add_child(path)
		trails.append_array(triangles(path))
		path.free()
	var catalog=preload("res://scripts/plant_catalog.gd").new()
	catalog.load_catalog()
	var loader=Placement.new()
	var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/plant_placements.json"))
	var repair: bool="--repair" in OS.get_cmdline_user_args()
	if data.placements.size()!=21 or loader.validate(data,catalog).size()!=21:
		push_error("Expected exactly 21 valid catalog placements")
		landscape.free()
		quit(1)
		return
	# A known on-path footprint must be detected as an intersection (negative fixture).
	if clearance(AABB(Vector3(-.1,0,-.1),Vector3(.2,.6,.2)))!=0.0:
		push_error("Trail intersection negative fixture was not detected")
		landscape.free()
		quit(1)
		return
	var failures:=0
	var smallest:=INF
	for entry in data.placements:
		var visual: Node3D=(load(catalog.find_species(entry.species_id).model) as PackedScene).instantiate()
		visual.scale=Vector3.ONE*Placement.VISUAL_SCALE
		var local_box: AABB=loader.visual_bounds(visual)
		var at:=Vector3(entry.position[0],entry.position[1],entry.position[2])
		var old_distance:=clearance(AABB(local_box.position+at,local_box.size))
		if repair:
			var side:=1.0 if int(str(entry.species_id).get_slice("-",1))%2==1 else -1.0
			# Search from the old point outward, using real mesh triangles, never a sine-width approximation.
			var found:=false
			for step in range(401):
				var candidate:=at+Vector3(side*step*.025,0,0)
				var distance:=clearance(AABB(local_box.position+candidate,local_box.size))
				if distance>=.85 and distance<=1.15:
					at=candidate;found=true;break
			assert(found,"No lawn placement found: "+str(entry.species_id))
			var height:=terrain_height(xz(at))
			assert(is_finite(height),"No lawn terrain below plant")
			at.y=height-local_box.position.y+.008
			entry.position=[at.x,at.y,at.z]
		var box:=AABB(local_box.position+at,local_box.size)
		var distance:=clearance(box)
		smallest=minf(smallest,distance)
		var supported:=true
		for x in [box.position.x,box.end.x]:
			for z in [box.position.z,box.end.z]:supported=supported and is_finite(terrain_height(Vector2(x,z)))
		var in_level: bool=box.position.x>=-47 and box.end.x<=51 and box.position.z>=-208 and box.end.z<=22
		var reach_distance:=reachable_from_trail(box)
		var reachable: bool=reach_distance<3.2
		var valid: bool=distance>=.8 and in_level and supported and reachable
		if not valid:failures+=1
		print("PLANT ",entry.species_id," old_clearance=",snappedf(old_distance,.0001)," clearance=",snappedf(distance,.0001)," position=",at," lawn=",supported," reach_m=",snappedf(reach_distance,.0001)," reachable=",reachable," valid=",valid)
		visual.free()
	if repair:
		var file:=FileAccess.open("res://data/plant_placements.json",FileAccess.WRITE)
		file.store_string(JSON.stringify(data,"  ")+"\n")
		file.close()
	landscape.free()
	print("TRAIL CLEARANCE ","PASS" if failures==0 else "FAIL"," plants=",data.placements.size()," triangles=",trails.size()," minimum=",smallest," failures=",failures)
	quit(0 if failures==0 else 1)
