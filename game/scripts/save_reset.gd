extends RefCounted
const FILES: Array[String]=["progress.cfg","photo_journal.json","route_markers.json"]
static func begin_new_game(base:String="user://") -> Dictionary:
	var folder:=base+"save_backups/"+str(Time.get_unix_time_from_system()).replace(".","_")
	var error:=DirAccess.make_dir_recursive_absolute(folder)
	if error!=OK:return {"error":error,"backup":""}
	# Complete all backups before resetting any file. Photo PNGs are never deleted.
	for name in FILES:
		if not FileAccess.file_exists(base+name):continue
		error=DirAccess.copy_absolute(base+name,folder+"/"+name)
		if error!=OK:return {"error":error,"backup":folder}
	var fresh:=ConfigFile.new()
	fresh.set_value("progress","xp",0)
	fresh.set_value("progress","spent",0)
	error=fresh.save(base+"progress.cfg")
	if error==OK:
		for name in ["photo_journal.json","route_markers.json"]:
			var file:=FileAccess.open(base+name,FileAccess.WRITE)
			if file==null:error=FileAccess.get_open_error();break
			file.store_string("[]")
			file.close()
	if error!=OK:
		for name in FILES:
			if FileAccess.file_exists(folder+"/"+name):DirAccess.copy_absolute(folder+"/"+name,base+name)
	return {"error":error,"backup":folder}
