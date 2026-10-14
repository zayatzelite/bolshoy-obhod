extends Node3D
var elapsed := 0.0
var birds: Array[Node3D] = []
func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("35443c")
	material.roughness = 1
	for index in range(7):
		var bird := Node3D.new()
		add_child(bird)
		birds.append(bird)
		for side in [-1,1]:
			var wing := MeshInstance3D.new()
			var mesh := PrismMesh.new()
			mesh.size = Vector3(.55,.06,.24)
			wing.mesh = mesh
			wing.position.x = side*.23
			wing.material_override = material
			wing.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			bird.add_child(wing)
	update_flight(0)
func update_flight(delta: float) -> void:
	elapsed += delta
	for index in range(birds.size()):
		var angle := elapsed*.09+index*.26
		var bird := birds[index]
		bird.position = Vector3(12+24*cos(angle),18+index*.35+sin(angle*2)*1.2,-85+46*sin(angle))
		bird.rotation.y = atan2(-24*sin(angle),46*cos(angle))
		var flap := sin(elapsed*4+index*.7)*.42
		bird.get_child(0).rotation.z = flap
		bird.get_child(1).rotation.z = -flap
func _process(delta: float) -> void:
	if get_parent().has_method("is_patrol_paused") and get_parent().is_patrol_paused():return
	update_flight(delta)
