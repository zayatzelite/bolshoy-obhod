extends "res://scripts/progression.gd"
var saves := 0
func save_progress() -> Error:
	saves+=1
	return OK
