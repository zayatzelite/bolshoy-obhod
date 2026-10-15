extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var base:="user://reset_fixture_"+str(Time.get_ticks_usec())+"/"
	assert(DirAccess.make_dir_recursive_absolute(base)==OK)
	var cfg:=ConfigFile.new();cfg.set_value("progress","xp",765);cfg.save(base+"progress.cfg")
	for name in ["photo_journal.json","route_markers.json"]:
		var f:=FileAccess.open(base+name,FileAccess.WRITE);f.store_string("[1]");f.close()
	var result=preload("res://scripts/save_reset.gd").begin_new_game(base)
	assert(result.error==OK)
	cfg.load(base+"progress.cfg");assert(cfg.get_value("progress","xp")==0)
	cfg.load(result.backup+"/progress.cfg");assert(cfg.get_value("progress","xp")==765)
	for name in ["photo_journal.json","route_markers.json"]:
		assert(FileAccess.get_file_as_string(base+name)=="[]")
		assert(FileAccess.get_file_as_string(result.backup+"/"+name)=="[1]")
	print("SAVE RESET PASS: reset and backups verified in isolated fixture; real saves untouched")
	quit()
