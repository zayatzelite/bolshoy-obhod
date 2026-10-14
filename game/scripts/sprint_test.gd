extends SceneTree
func _initialize() -> void:
	var player := CharacterBody3D.new()
	player.set_script(load("res://scripts/player.gd"))
	assert(player.can_sprint(true,true))
	player.stamina = 1
	assert(not player.can_sprint(true,true))
	for value in [3,8,19]:
		player.stamina = value
		assert(not player.can_sprint(true,true))
	player.stamina = 20
	assert(player.can_sprint(true,true))
	assert(not player.can_sprint(true,false))
	assert(not player.can_sprint(false,true))
	player.dragging = true
	assert(not player.can_sprint(true,true))
	player.free()
	print("SPRINT PASS: exhaustion locks sprint until 20 stamina, no sprint when idle or dragging")
	quit()
