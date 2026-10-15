extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var world=load("res://scenes/world.tscn").instantiate();root.add_child(world)
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	var event:=InputEventKey.new();event.pressed=true;event.keycode=1060;event.physical_keycode=KEY_J
	world._unhandled_input(event)
	assert(is_instance_valid(world.overlay) and world.overlay.find_child("JournalTabs",true,false)!=null)
	print("KEYBOARD LAYOUT PASS: physical J opens journal with non-Latin logical key")
	quit()
