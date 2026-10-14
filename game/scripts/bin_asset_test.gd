extends SceneTree
func _initialize() -> void:
	var asset: Node3D = load("res://assets/detailed_waste_bin.glb").instantiate()
	var meshes := 0
	for node in asset.find_children("*","MeshInstance3D",true,false):
		meshes+=1
		assert(node.mesh.get_surface_count()==3)
		var size: Vector3 = node.mesh.get_aabb().size
		assert(size.y>.8 and size.y<1 and size.x<.8)
	assert(meshes==1)
	asset.free()
	print("BIN ASSET PASS: one mesh, three material surfaces, expected metre scale")
	quit()
