extends Control
var player_position := Vector3.ZERO
var cart_position := Vector3.ZERO
var bases: Array = []
func project_position(p: Vector3) -> Vector2:
	return Vector2(size.x*.30+p.x*4.3,25+(-p.z+12)*2.0)
func _draw() -> void:
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color("d0ba8e")
	paper.border_color = Color("8d714c")
	paper.set_border_width_all(2)
	paper.set_corner_radius_all(6)
	draw_style_box(paper,Rect2(Vector2.ZERO,size))
	var river := PackedVector2Array()
	for step in range(31):river.append(project_position(Vector3(85,0,15-step*8)))
	draw_polyline(river,Color("bfa675"),285,true)
	draw_polyline(river,Color("689995"),258,true)
	# Decorative land-cover symbols, not botanical species markers.
	for index in range(100):
		var p := project_position(Vector3(-44+fmod(index*23.71,90),0,-fmod(index*17.63,194)))
		if absf(p.x-size.x*.30)<25:continue
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-7),p+Vector2(-5,4),p+Vector2(5,4)]),Color("82906a"))
	for index in range(26):
		var p := project_position(Vector3(132+3*sin(index*.9),0,-35-index*4.8))
		draw_colored_polygon(PackedVector2Array([p+Vector2(-5,6),p+Vector2(-4,-11),p+Vector2(2,-15),p+Vector2(7,5)]),Color("a18c63"))
	var main := PackedVector2Array()
	var branch := PackedVector2Array()
	for d in range(-5,186):main.append(project_position(Vector3(2.5*sin(d*.035),0,-d)))
	for d in range(55,156):branch.append(project_position(Vector3(2.5*sin(d*.035)-22*sin((d-55)*PI/100),0,-d)))
	draw_polyline(main,Color("6f5639"),7,true)
	draw_polyline(main,Color("f3dfaa"),4,true)
	draw_polyline(branch,Color("6f5639"),5,true)
	draw_polyline(branch,Color("ecce96"),2,true)
	var forest_loop := PackedVector2Array()
	for d in range(20,66):forest_loop.append(project_position(preload("res://scripts/exploration_path.gd").point(d)))
	draw_polyline(forest_loop,Color("6f5639"),5,true)
	draw_polyline(forest_loop,Color("ecce96"),2,true)
	var approach := PackedVector2Array()
	for index in range(65):approach.append(project_position(preload("res://scripts/base_approach.gd").point(index/64.0)))
	draw_polyline(approach,Color("6f5639"),7,true)
	draw_polyline(approach,Color("ecce96"),4,true)
	var shore := PackedVector2Array()
	for index in range(65):shore.append(project_position(preload("res://scripts/shore_connector.gd").point(index/64.0)))
	draw_polyline(shore,Color("6f5639"),5,true)
	draw_polyline(shore,Color("ecce96"),3,true)
	for index in range(bases.size()):
		var p := project_position(bases[index])
		var path_point := project_position(Vector3(2.5*sin(-bases[index].z*.035),0,bases[index].z)) if index==0 else project_position(preload("res://scripts/base_approach.gd").point(1))
		draw_line(p,path_point,Color("6f5639"),3,true)
		draw_rect(Rect2(p-Vector2(8,5),Vector2(16,13)),Color("604f39"))
		draw_colored_polygon(PackedVector2Array([p+Vector2(-12,-5),p+Vector2(0,-15),p+Vector2(12,-5)]),Color("604f39"))
	var cart := project_position(cart_position)
	draw_rect(Rect2(cart-Vector2(7,5),Vector2(14,10)),Color("397e85"))
	for x in [-5,5]:draw_circle(cart+Vector2(x,7),2,Color("2c4545"))
	var marker := project_position(player_position)
	draw_circle(marker,9,Color("f9edd0"))
	draw_arc(marker,11,0,TAU,32,Color("b2634b"),3,true)
	draw_string(ThemeDB.fallback_font,Vector2(size.x-50,35),"С",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("604f39"))
	draw_line(Vector2(size.x-42,43),Vector2(size.x-42,70),Color("604f39"),2)
