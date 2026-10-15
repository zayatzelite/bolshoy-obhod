extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var character=load("res://assets/ranger_character.glb").instantiate()
	root.add_child(character)
	var skeletons=character.find_children("*","Skeleton3D",true,false)
	var animations=character.find_children("*","AnimationPlayer",true,false)
	assert(skeletons.size()==1 and skeletons[0].get_bone_count()>=15)
	assert(animations.size()==1)
	var player:AnimationPlayer=animations[0]
	print("CHARACTER meshes: ",character.find_children("*","MeshInstance3D",true,false).map(func(mesh):return mesh.name))
	print("CHARACTER animations: ",player.get_animation_list())
	for name in player.get_animation_list():
		if name=="RESET":continue
		player.play(name)
		await create_timer(.12).timeout
		assert(player.is_playing())
	print("CHARACTER IMPORT PASS: skeleton and imported animation playback")
	quit()
