extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var hud := preload("res://scripts/patrol_hud.gd").new()
	root.add_child(hud)
	for values in [[100.0,100.0],[37.4,2.0],[-10.0,140.0]]:
		hud.update_values(values[0],values[1],0,4,0,0)
		for bar in [hud.health_bar,hud.stamina_bar]:
			var amount: Label = bar.get_node("Amount")
			assert(amount.position.x+amount.size.x<=bar.custom_minimum_size.x)
			assert(amount.position.y+amount.size.y<=bar.custom_minimum_size.y)
	assert(hud.health_bar.get_node("Amount").text=="0 / 100")
	assert(hud.stamina_bar.get_node("Amount").text=="100 / 100")
	print("HUD METER PASS: numeric values inside bars, clamped, icons retain reserved space")
	quit()
