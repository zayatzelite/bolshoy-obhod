extends "res://scripts/ui_regression_test.gd"
func setup() -> void:
	super.setup()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
func _process(delta: float) -> bool:
	if ticks>2:
		assert(DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN)
		assert(DisplayServer.window_get_size()==Vector2i(1920,1080))
	return super._process(delta)
