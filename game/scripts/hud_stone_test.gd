extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var hud := preload("res://scripts/patrol_hud.gd").new()
	root.add_child(hud)
	for tick in range(5):await process_frame
	var count := 0
	for card in hud.get_children():
		if card.has_meta("stone_backdrop"):
			count+=1
			var backdrop: Control = card.get_meta("stone_backdrop")
			assert(backdrop.size==card.size,"Stone backdrop size mismatch")
			assert(backdrop.size.x>0 and backdrop.size.y>0)
	assert(count==10)
	print("HUD STONE PASS: all ten backdrops match their card size at initial layout")
	quit()
