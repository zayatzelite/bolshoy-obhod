extends RefCounted
static func point(t: float) -> Vector3:
	var a := Vector3(-2.4,0,-143)
	var control_a := Vector3(10,0,-141)
	var control_b := Vector3(30,0,-139)
	var b := Vector3(30,0,-146.35)
	var u := 1-t
	var p := a*u*u*u+control_a*3*u*u*t+control_b*3*u*t*t+b*t*t*t
	p.y = .12*sin(p.x*.12)*sin(-p.z*.08)+.05
	return p
static func excluded(p: Vector3) -> bool:
	for index in range(65):
		var center := point(index/64.0)
		if Vector2(p.x-center.x,p.z-center.z).length()<2.1:return true
	return false
static func side(t: float) -> Vector3:
	var tangent := point(t+.0005)-point(t-.0005)
	return Vector3(-tangent.z,0,tangent.x).normalized()*1.6
static func edge(t: float,sign_value: float) -> Vector3:
	var p := point(t)+side(t)*sign_value
	p.y = .12*sin(p.x*.12)*sin(-p.z*.08)+.05
	return p
static func build() -> MeshInstance3D:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(64):
		var t := index/64.0
		var nt := (index+1)/64.0
		for p in [edge(t,-1),edge(nt,-1),edge(t,1),edge(nt,-1),edge(nt,1),edge(t,1)]:
			surface.add_vertex(p)
	surface.generate_normals()
	var mesh := MeshInstance3D.new()
	mesh.name = "Riverside base approach"
	mesh.mesh = surface.commit()
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/trail_ground.gdshader")
	mesh.material_override = material
	return mesh
