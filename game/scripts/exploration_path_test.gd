extends SceneTree
func _initialize() -> void:
	var path = preload("res://scripts/exploration_path.gd")
	var mesh: MeshInstance3D = path.build()
	assert(mesh.mesh.get_faces().size()==540)
	for d in range(20,66):
		var p: Vector3 = path.point(d)
		assert(p.x>-47 and p.x<51 and is_finite(p.y))
	for d in [20.0,65.0]:assert(absf(path.point(d).x-2.5*sin(d*.035))<.001)
	mesh.free()
	print("EXPLORATION PATH PASS: 180 triangles, both joins match main trail, all points within playable limits")
	quit()
