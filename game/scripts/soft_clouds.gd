extends Node3D
var time := 0.0
var groups: Array[Node3D] = []
var origins: Array[Vector3] = []
func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 842
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/soft_cloud.gdshader")
	var sphere := SphereMesh.new()
	sphere.radius = 1
	sphere.height = 2
	sphere.radial_segments = 24
	sphere.rings = 12
	for index in range(16):
		var group := Node3D.new()
		group.position = Vector3(rng.randf_range(-95,105),rng.randf_range(32,48),rng.randf_range(-240,30))
		add_child(group)
		groups.append(group)
		origins.append(group.position)
		for puff in range(10):
			var mesh := MeshInstance3D.new()
			mesh.mesh = sphere
			mesh.material_override = material
			var upper := puff>=6
			var angle := TAU*(puff%6)/6.0
			mesh.position = Vector3(cos(angle)*(2.6 if upper else 4.1),rng.randf_range(1.4,2.7) if upper else rng.randf_range(-.3,.3),sin(angle)*2.1)
			mesh.scale = Vector3(rng.randf_range(2.4,4.0),rng.randf_range(2.2,3.5) if upper else rng.randf_range(1.2,1.9),rng.randf_range(2.2,3.4))
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			group.add_child(mesh)
func _process(delta: float) -> void:
	if get_parent().has_method("is_patrol_paused") and get_parent().is_patrol_paused():return
	time+=delta
	for index in range(groups.size()):groups[index].position = origins[index]+Vector3(10*sin(time*.008),0,0)
