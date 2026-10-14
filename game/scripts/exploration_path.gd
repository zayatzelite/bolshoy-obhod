extends RefCounted
static func point(d: float) -> Vector3:
	var x := 2.5*sin(d*.035)-29*sin((d-20)*PI/45)
	var y := .12*sin(x*.12)*sin(d*.08)+maxf(0,(-x-15)*.025)*(.5+.5*sin(d*.025))+.025
	return Vector3(x,y,-d)
static func build() -> MeshInstance3D:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for step in range(90):
		var d := 20+step*.5
		var a := point(d)
		var b := point(d+.5)
		var tangent_a := point(d+.05)-point(d-.05)
		var tangent_b := point(d+.55)-point(d+.45)
		var side_a := Vector3(-tangent_a.z,0,tangent_a.x).normalized()*1.15
		var side_b := Vector3(-tangent_b.z,0,tangent_b.x).normalized()*1.15
		for vertex in [a-side_a,b-side_b,a+side_a,b-side_b,b+side_b,a+side_a]:
			vertex.y = .12*sin(vertex.x*.12)*sin(-vertex.z*.08)+maxf(0,(-vertex.x-15)*.025)*(.5+.5*sin(-vertex.z*.025))+.045
			surface.add_vertex(vertex)
	surface.generate_normals()
	var mesh := MeshInstance3D.new()
	mesh.name = "Forest exploration loop"
	mesh.mesh = surface.commit()
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/trail_ground.gdshader")
	mesh.material_override = material
	return mesh
