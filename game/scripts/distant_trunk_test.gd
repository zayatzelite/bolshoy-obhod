extends SceneTree
var count := 0
func inspect_node(node: Node) -> void:
	if str(node.name).begins_with("Distant forest crown"):
		count+=1
		var trunk: MeshInstance3D = node.get_node("DistantTrunk")
		assert(trunk.mesh.height>0)
		assert(trunk.visible)
	for child in node.get_children():inspect_node(child)
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	inspect_node(scene)
	assert(count>=100)
	print("DISTANT TRUNK PASS: ",count," separate distant crowns now have visible grounded trunks")
	quit()
