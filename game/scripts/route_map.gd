extends Control
signal waypoint_changed(destination: Vector3, active: bool)
var player_position := Vector3.ZERO
var cart_position := Vector3.ZERO
var bases: Array = []
var plant_points:Array[Vector3]=[]
var plant_names:PackedStringArray=[]
var player_heading:=0.0
func _ready() -> void:
	mouse_default_cursor_shape=Control.CURSOR_CROSS
func _process(_delta:float) -> void:
	var cursor:=get_local_mouse_position()
	var hint:=""
	for index in range(plant_points.size()):
		if project_position(plant_points[index]).distance_to(cursor)<16:
			hint=plant_names[index] if index<plant_names.size() else "Охраняемое растение"
			break
	if hint.is_empty():
		for index in range(bases.size()):
			if project_position(bases[index]).distance_to(cursor)<20:hint="Стартовая база" if index==0 else "Дальняя база"
	tooltip_text=hint
var waypoints: Array[Vector2] = []
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index==MOUSE_BUTTON_LEFT:
			if waypoints.size()>=8:waypoints.pop_front()
			waypoints.append(event.position/size)
		elif event.button_index==MOUSE_BUTTON_RIGHT:
			var closest:=-1
			var distance:=28.0
			for i in range(waypoints.size()):
				var d:=(waypoints[i]*size).distance_to(event.position)
				if d<distance:closest=i;distance=d
			if closest>=0:waypoints.remove_at(closest)
		waypoint_changed.emit(unproject_position(waypoints.back()) if not waypoints.is_empty() else Vector3.ZERO,not waypoints.is_empty())
		queue_redraw()
		accept_event()
func project_position(p: Vector3) -> Vector2:
	return Vector2((330+p.x*4.3)/1100.0*size.x,(25+(-p.z+12)*2.0)/480.0*size.y)
func unproject_position(normalized: Vector2) -> Vector3:
	return Vector3((normalized.x*1100.0-330)/4.3,0,12-(normalized.y*480.0-25)/2.0)
func _draw() -> void:
	var paper := StyleBoxFlat.new()
	clip_contents=true
	paper.bg_color = Color("d0ba8e")
	paper.border_color = Color("8d714c")
	paper.set_border_width_all(2)
	paper.set_corner_radius_all(6)
	draw_style_box(paper,Rect2(Vector2.ZERO,size))
	draw_rect(Rect2(Vector2(8,8),size-Vector2(16,16)),Color("8d714c"),false,1)
	draw_rect(Rect2(Vector2(12,12),size-Vector2(24,24)),Color(.55,.44,.29,.35),false,1)
	for corner in [Vector2(18,18),Vector2(size.x-18,18),Vector2(18,size.y-18),size-Vector2(18,18)]:
		var direction:=Vector2(1 if corner.x<size.x*.5 else -1,1 if corner.y<size.y*.5 else -1)
		draw_line(corner,corner+direction*Vector2(24,0),Color("745431"),2,true)
		draw_line(corner,corner+direction*Vector2(0,24),Color("745431"),2,true)
		draw_circle(corner+direction*Vector2(5,5),2,Color("745431"))
	# Hand-drafted contour rings and translucent forest washes.
	for hill in range(7):
		var center:=Vector2(60+fmod(hill*131.0,size.x*.52),75+hill*47)
		for ring in range(4):
			var contour:=PackedVector2Array()
			for step in range(49):
				var a:=step/48.0*TAU
				var radius:=28+ring*12+sin(a*3+hill)*5
				contour.append(center+Vector2(cos(a)*radius,sin(a)*radius*.55))
			draw_polyline(contour,Color("ae986f"),1,true)
	for patch in range(16):
		var center:=project_position(Vector3(-38+fmod(patch*19.31,76),0,-15-fmod(patch*27.7,175)))
		draw_circle(center,18+fmod(patch*9.3,17),Color(.35,.43,.25,.14))
	for x in range(40,int(size.x),70):draw_line(Vector2(x,0),Vector2(x,size.y),Color(.4,.3,.17,.09),1)
	for y in range(40,int(size.y),70):draw_line(Vector2(0,y),Vector2(size.x,y),Color(.4,.3,.17,.09),1)
	var river := PackedVector2Array()
	for step in range(31):
		var t:=step/30.0
		river.append(Vector2(size.x*(.61+.014*sin(t*5)),t*size.y))
	for step in range(30,-1,-1):
		var t:=step/30.0
		river.append(Vector2(size.x*(.75+.012*sin(t*5+.5)),t*size.y))
	draw_colored_polygon(river,Color("689995"))
	var bank:=PackedVector2Array()
	for step in range(31):
		var t:=step/30.0
		bank.append(Vector2(size.x*(.61+.014*sin(t*5)),t*size.y))
	draw_polyline(bank,Color("aa936b"),4,true)
	for ripple in range(18):
		var t:float=(ripple+.5)/18
		var x:float=size.x*(.65+.014*sin(t*5))
		draw_line(Vector2(x,t*size.y),Vector2(x+size.x*.035,t*size.y),Color(.86,.91,.81,.22),1,true)
	# Decorative land-cover symbols, not botanical species markers.
	for index in range(100):
		var p := project_position(Vector3(-44+fmod(index*23.71,90),0,-fmod(index*17.63,194)))
		if absf(p.x-size.x*.30)<25:continue
		draw_line(p+Vector2(0,2),p+Vector2(0,9),Color("665b3b"),1,true)
		var crown:=PackedVector2Array([p+Vector2(0,-8),p+Vector2(-5,1),p+Vector2(-3,1),p+Vector2(-6,5),p+Vector2(6,5),p+Vector2(3,1),p+Vector2(5,1)])
		draw_colored_polygon(crown,Color("82906a"))
		crown.append(crown[0])
		draw_polyline(crown,Color(.31,.38,.23,.6),.7,true)
	for index in range(26):
		var p := project_position(Vector3(132+3*sin(index*.9),0,-35-index*4.8))
		draw_colored_polygon(PackedVector2Array([p+Vector2(-5,6),p+Vector2(-4,-11),p+Vector2(2,-15),p+Vector2(7,5)]),Color("a18c63"))
		draw_line(p+Vector2(2,-13),p+Vector2(2,4),Color("786546"),1,true)
		for layer in range(3):
			draw_line(p+Vector2(-3,-7+layer*4),p+Vector2(4,-8+layer*4),Color(.42,.34,.22,.45),1,true)
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
		var caption:= "БАЗА / СТАРТ" if index==0 else "ДАЛЬНЯЯ БАЗА"
		draw_string(ThemeDB.fallback_font,p+Vector2(17,4),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("604f39"))
	for point in plant_points:
		var p:=project_position(point)
		draw_circle(p,4,Color("4c7551"))
		draw_line(p+Vector2(0,4),p+Vector2(0,8),Color("4c7551"),1,true)
	for i in range(waypoints.size()):
		var p:=waypoints[i]*size
		draw_circle(p,10,Color("f5e7c8"))
		draw_circle(p,7,Color("a75a3e"))
		draw_string(ThemeDB.fallback_font,p+Vector2(12,4),str(i+1),HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("604f39"))
	draw_string(ThemeDB.fallback_font,Vector2(36,size.y-22),"ЛКМ — метка · ПКМ — удалить · до 8 меток",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("604f39"))
	var legend_origin:=Vector2(size.x-220,size.y-102)
	draw_rect(Rect2(legend_origin-Vector2(10,18),Vector2(205,94)),Color(.96,.89,.72,.85))
	for i in range(4):
		var label_position:=legend_origin+Vector2(22,i*21)
		var legend_color:Color= [Color("b2634b"),Color("397e85"),Color("a75a3e"),Color("4c7551")][i]
		draw_circle(label_position-Vector2(13,4),4,legend_color)
		draw_string(ThemeDB.fallback_font,label_position,["Вы","Тележка","Метки","Растения"][i],HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("604f39"))
	var cart := project_position(cart_position)
	draw_rect(Rect2(cart-Vector2(7,5),Vector2(14,10)),Color("397e85"))
	for x in [-5,5]:draw_circle(cart+Vector2(x,7),2,Color("2c4545"))
	var marker := project_position(player_position)
	draw_circle(marker,9,Color("f9edd0"))
	draw_arc(marker,11,0,TAU,32,Color("b2634b"),3,true)
	var ahead:=Vector2(-sin(player_heading),-cos(player_heading))
	var side:=Vector2(-ahead.y,ahead.x)
	draw_colored_polygon(PackedVector2Array([marker+ahead*20,marker+ahead*10+side*5,marker+ahead*10-side*5]),Color("b2634b"))
	draw_string(ThemeDB.fallback_font,Vector2(size.x-50,35),"С",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("604f39"))
	draw_line(Vector2(size.x-42,43),Vector2(size.x-42,70),Color("604f39"),2)
	var rose:=Vector2(size.x-42,53)
	draw_arc(rose,25,0,TAU,48,Color(.38,.31,.22,.45),1,true)
	draw_colored_polygon(PackedVector2Array([rose+Vector2(0,-22),rose+Vector2(-5,0),rose,rose+Vector2(5,0)]),Color("604f39"))
	for tick in range(8):
		var direction:=Vector2(sin(tick*PI/4),-cos(tick*PI/4))
		draw_line(rose+direction*27,rose+direction*30,Color("604f39"),1,true)
