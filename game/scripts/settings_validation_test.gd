extends SceneTree
func _initialize() -> void:
	var settings = preload("res://scripts/game_settings.gd")
	var clean: Dictionary = settings.sanitize({"volume":500,"fov":-20,"sensitivity":99,"fullscreen":"yes","shadows":null,"invert_y":true})
	assert(clean.volume==100 and clean.fov==60 and clean.sensitivity==.006)
	assert(clean.fullscreen==false and clean.shadows==true and clean.invert_y==true)
	clean = settings.sanitize({"volume":"broken","fov":NAN,"sensitivity":INF,"unknown":123})
	assert(clean.volume==80 and clean.fov==78 and clean.sensitivity==.0025)
	assert(not clean.has("unknown"))
	print("SETTINGS VALIDATION PASS: clamps numeric ranges, rejects wrong types and nonfinite values, ignores unknown keys; no user save modified")
	quit()
