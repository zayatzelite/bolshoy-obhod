extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	var caps=scene.find_children("Continuous roof ridge cap","MeshInstance3D",true,false)
	var trims=scene.find_children("Roof end joint trim*","MeshInstance3D",true,false)
	print("DETAIL COUNTS ",caps.size()," ",trims.size())
	for node in scene.find_children("*","MeshInstance3D",true,false):
		if node.get_parent().name.begins_with("Cabin roof"):print(node.name)
	if caps.size()!=2 or trims.size()!=8:quit(1);return
	for cap in caps:
		assert(cap.mesh.size==Vector3(.28,.16,7.85))
		assert(absf(cap.position.y-4.50)<.001)
	for trim in trims:assert(trim.mesh.size.y==1.5)
	print("ROOF DETAIL PASS: both bases have ridge caps and four thinner end trims; visual watertightness not asserted")
	quit()
