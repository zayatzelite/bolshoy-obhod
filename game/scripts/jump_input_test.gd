extends SceneTree
func _initialize() -> void:
	var player := CharacterBody3D.new()
	player.set_script(load("res://scripts/player.gd"))
	assert(not player.consume_jump_press(false))
	assert(player.consume_jump_press(true))
	for tick in range(180):assert(not player.consume_jump_press(true))
	assert(not player.consume_jump_press(false))
	assert(player.consume_jump_press(true))
	player.free()
	print("JUMP INPUT PASS: holding space does not retrigger, release and fresh press permits new jump")
	quit()
