extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var stream=preload("res://scripts/patrol_audio.gd").shutter()
	assert(stream.data.size()>6000 and stream.get_length()>.1 and stream.get_length()<.2)
	var holder:=Node.new();root.add_child(holder)
	preload("res://scripts/patrol_audio.gd").play_shutter(holder)
	assert(holder.get_child_count()==1)
	await create_timer(.35).timeout
	assert(holder.get_child_count()==0)
	print("SHUTTER AUDIO PASS: authored PCM click plays and frees itself")
	quit()
