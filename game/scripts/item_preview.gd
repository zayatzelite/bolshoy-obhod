extends SubViewportContainer
var title: String = "":
	set(value):
		if title==value:return
		title=value
		if is_node_ready():refresh()
var viewport: SubViewport
var stage: Node3D
var model: Node3D
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	stretch=true
	viewport=SubViewport.new()
	viewport.size=Vector2i(96,96)
	viewport.transparent_bg=true
	viewport.own_world_3d=true
	viewport.render_target_update_mode=SubViewport.UPDATE_ONCE
	add_child(viewport)
	stage=Node3D.new()
	viewport.add_child(stage)
	var camera:=Camera3D.new()
	camera.position=Vector3(1.8,1.1,2.4)
	stage.add_child(camera)
	camera.look_at(Vector3.ZERO)
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	camera.size=1.5
	var light:=DirectionalLight3D.new()
	light.rotation_degrees=Vector3(-40,-35,0)
	light.light_energy=1.4
	stage.add_child(light)
	refresh()
func refresh() -> void:
	if is_instance_valid(model):model.queue_free()
	if title.is_empty():
		viewport.render_target_update_mode=SubViewport.UPDATE_ONCE
		return
	var path:="res://assets/litter_cup.glb"
	if "бут" in title.to_lower():path="res://assets/litter_bottle.glb"
	elif "банк" in title.to_lower():path="res://assets/litter_can.glb"
	model=load(path).instantiate()
	stage.add_child(model)
	var bounds:=AABB()
	var found:=false
	for node in model.find_children("*","MeshInstance3D",true,false):
		var mesh:=node as MeshInstance3D
		var local:=model.global_transform.affine_inverse()*mesh.global_transform
		var box: AABB = local*mesh.get_aabb()
		bounds=box if not found else bounds.merge(box)
		found=true
	if found:
		var extent:=maxf(bounds.size.x,maxf(bounds.size.y,bounds.size.z))
		var factor:=1.05/maxf(extent,.001)
		model.scale=Vector3.ONE*factor
		model.position=-bounds.get_center()*factor
	viewport.render_target_update_mode=SubViewport.UPDATE_ONCE
