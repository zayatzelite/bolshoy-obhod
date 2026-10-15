extends SceneTree
var scene: Node3D
var ticks := 0
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.delivered = 8
	scene.session_xp = 200
	scene.session_seconds = 125
	scene.walked_distance = 185
	scene.show_results()
func _process(_delta: float) -> bool:
	if not is_instance_valid(scene):return false
	ticks+=1
	if ticks>=3 and scene.overlay.modulate.a>=.999:
		var rect: Rect2 = scene.overlay.get_global_rect()
		assert(rect==Rect2(0,0,1280,720))
		var text:=""
		for label:Label in scene.overlay.find_children("*","Label",true,false):text+=label.text+"\n"
		var buttons:Array=scene.overlay.find_children("*","Button",true,false)
		assert(buttons.size()==1)
		assert(buttons[0].get_global_rect().end.y<=720)
		assert(text.contains("2 мин 05 с") and text.contains("185 м") and text.contains("200"))
		root.get_texture().get_image().save_png("res://../patrol_results_preview.png")
		print("RESULTS PASS: bounded panel, time, distance and session XP")
		quit()
	return false
