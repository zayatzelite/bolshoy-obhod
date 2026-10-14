extends SceneTree
var scene: Node3D
var ticks := 0
func _initialize() -> void:call_deferred("setup")
func setup() -> void:
	scene = load("res://scenes/world.tscn").instantiate()
	root.add_child(scene)
	scene.map_menu()
func _process(_delta: float) -> bool:
	if not is_instance_valid(scene):return false
	ticks+=1
	if ticks==8:
		var rect: Rect2 = scene.overlay.get_global_rect()
		assert(rect.end.x<=1280 and rect.end.y<=720)
		var map = scene.overlay.get_child(0).get_child(2)
		assert(map.cart_position.is_equal_approx(scene.cart.position))
		assert(not scene.hud.visible)
		root.get_texture().get_image().save_png("res://../patrol_map_preview.png")
		print("MAP PASS: schematic and return button bounded by viewport")
		quit()
	return false
