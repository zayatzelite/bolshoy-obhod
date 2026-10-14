extends SceneTree
class PauseHost extends Node3D:
	var paused := false
	func is_patrol_paused() -> bool:return paused
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var host:=PauseHost.new()
	root.add_child(host)
	var clouds=preload("res://scripts/soft_clouds.gd").new()
	host.add_child(clouds)
	clouds.set_process(false)
	assert(clouds.groups.size()==16)
	for group in clouds.groups:
		assert(group.get_child_count()==10)
		var min_z:=100.0
		var max_z:=-100.0
		var upper:=0
		for puff in group.get_children():
			min_z=minf(min_z,puff.position.z)
			max_z=maxf(max_z,puff.position.z)
			if puff.position.y>1:upper+=1
		assert(max_z-min_z>3 and upper==4)
	var origin: Vector3=clouds.groups[0].position
	clouds._process(10)
	assert(clouds.groups[0].position.distance_to(origin)>.5)
	host.paused=true
	var stopped: Vector3=clouds.groups[0].position
	var stopped_time: float=clouds.time
	clouds._process(10)
	assert(clouds.groups[0].position==stopped and clouds.time==stopped_time)
	print("CLOUD VOLUME PASS: 16 groups, 10 puffs, depth and upper lobes, movement and pause freeze")
	quit()
