extends Control
var heading := 0.0
var target_angle := 0.0
var distance := 0
var target_label := "БАЗА"
func _draw() -> void:
	var ink:=Color("30271c")
	var backing:=PackedVector2Array([Vector2(12,4),Vector2(408,4),Vector2(418,14),Vector2(418,37),Vector2(2,37),Vector2(2,14)])
	draw_colored_polygon(backing,Color(.84,.72,.51,.98))
	draw_line(Vector2(14,5),Vector2(406,5),Color(.69,.59,.38,.5),1,true)
	draw_line(Vector2(14,36),Vector2(406,36),Color(.69,.59,.38,.35),1,true)
	for step in range(72):
		var bearing:=deg_to_rad(step*5.0)
		var offset:=wrapf(bearing-heading,-PI,PI)
		if absf(offset)>1.3:continue
		var x:=210+offset*145
		var major:=step%6==0
		draw_line(Vector2(x,27),Vector2(x,33 if major else 30),Color(ink,1.0 if major else .35),1,true)
		if major and absf(offset)>.22:draw_string(ThemeDB.fallback_font,Vector2(x-18,21),"%03d" % (step*5),HORIZONTAL_ALIGNMENT_CENTER,36,12,ink)
	draw_string(ThemeDB.fallback_font,Vector2(183,22),"%03d°" % posmod(roundi(rad_to_deg(heading)),360),HORIZONTAL_ALIGNMENT_CENTER,54,15,ink)
	draw_colored_polygon(PackedVector2Array([Vector2(210,2),Vector2(206,8),Vector2(214,8)]),ink)
	var target_x:=210+clampf(target_angle,-1.3,1.3)*145
	draw_colored_polygon(PackedVector2Array([Vector2(target_x,34),Vector2(target_x-4,40),Vector2(target_x+4,40)]),Color("e4b974"))
	var target_label_x:=clampf(target_x-65,0,290)
	draw_rect(Rect2(target_label_x-4,42,138,16),Color(.84,.72,.51,.98))
	draw_string(ThemeDB.fallback_font,Vector2(target_label_x,53),"%s · %d м" % [target_label,distance],HORIZONTAL_ALIGNMENT_CENTER,130,11,ink)
