extends Control
var title := ""
func _draw() -> void:
	var ink := Color("f3dfae")
	var shade := Color("72aaa0")
	if title.is_empty():
		draw_line(Vector2(23,24),Vector2(37,24),Color("998b70"),2)
	elif "бут" in title.to_lower():
		draw_style_box(make_box(shade),Rect2(19,16,22,29))
		draw_rect(Rect2(24,6,12,12),ink)
		draw_rect(Rect2(19,26,22,9),ink)
	elif "банк" in title.to_lower():
		draw_style_box(make_box(Color("bc8561")),Rect2(17,10,26,34))
		draw_line(Vector2(17,11),Vector2(43,11),ink,3)
		draw_line(Vector2(17,43),Vector2(43,43),ink,3)
	else:
		draw_colored_polygon(PackedVector2Array([Vector2(16,12),Vector2(44,12),Vector2(39,43),Vector2(21,43)]),ink)
		draw_line(Vector2(15,12),Vector2(45,12),shade,3)
func make_box(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(5)
	return box
