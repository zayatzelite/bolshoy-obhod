extends Control
var heading := 0.0
var target_angle := 0.0
var distance := 0
func _draw() -> void:
	var ink := Color("f3dfae")
	for step in range(8):
		var bearing := step*PI/4
		var offset := wrapf(bearing-heading,-PI,PI)
		if absf(offset)>1.3:continue
		var x := 210+offset*145
		draw_line(Vector2(x,26),Vector2(x,32),ink,1)
		var labels := ["С","СВ","В","ЮВ","Ю","ЮЗ","З","СЗ"]
		draw_string(ThemeDB.fallback_font,Vector2(x-9,20),labels[posmod(step,8)],HORIZONTAL_ALIGNMENT_LEFT,-1,13,ink)
	var x := 210+clampf(target_angle,-1.3,1.3)*145
	draw_colored_polygon(PackedVector2Array([Vector2(x,34),Vector2(x-5,42),Vector2(x+5,42)]),Color("e4b974"))
	draw_string(ThemeDB.fallback_font,Vector2(x-18,57),"%d м" % distance,HORIZONTAL_ALIGNMENT_LEFT,-1,12,ink)
	draw_line(Vector2(210,0),Vector2(210,7),ink,2)
