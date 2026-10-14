extends RefCounted
static func point(t: float) -> Vector3:
	var start := preload("res://scripts/base_approach.gd").point(.70)
	var finish := Vector3(52,0,-128)
	var p := start.lerp(finish,t)
	p.z-=2.5*sin(t*PI)
	p.y=.12*sin(p.x*.12)*sin(-p.z*.08)+.06
	return p
static func excluded(p: Vector3) -> bool:
	for i in range(65):
		var center:=point(i/64.0)
		if Vector2(p.x-center.x,p.z-center.z).length()<2.2:return true
	return false
static func edge(t: float,s: float) -> Vector3:
	var tangent:=point(t+.0005)-point(t-.0005)
	var p:=point(t)+Vector3(-tangent.z,0,tangent.x).normalized()*1.35*s
	p.y=.12*sin(p.x*.12)*sin(-p.z*.08)+.06
	return p
static func build() -> MeshInstance3D:
	var surface:=SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(64):
		var t:=i/64.0
		var nt:=(i+1)/64.0
		for p in [edge(t,-1),edge(nt,-1),edge(t,1),edge(nt,-1),edge(nt,1),edge(t,1)]:surface.add_vertex(p)
	surface.generate_normals()
	var mesh:=MeshInstance3D.new()
	mesh.name="Shore exploration connector"
	mesh.mesh=surface.commit()
	var material:=ShaderMaterial.new()
	material.shader=preload("res://shaders/trail_ground.gdshader")
	mesh.material_override=material
	return mesh
