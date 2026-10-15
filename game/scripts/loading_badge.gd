extends Control
var progress:=0.0
var phase:=0.0
func _ready() -> void:mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(delta:float) -> void:
	phase+=delta
	queue_redraw()
func _draw() -> void:
	var ink:=Color("30271c")
	var plate:=StyleBoxFlat.new()
	plate.bg_color=Color("d7bf91")
	plate.border_color=Color("877357")
	plate.set_border_width_all(1)
	plate.set_corner_radius_all(6)
	plate.shadow_color=Color(0,0,0,.3)
	plate.shadow_size=4
	draw_style_box(plate,Rect2(Vector2(-12,-8),size+Vector2(24,12)))
	draw_rect(Rect2(Vector2(-7,-3),size+Vector2(14,2)),Color("efdfbd"),false,1)
	for corner in [Vector2(-5,0),Vector2(size.x+5,size.y-2)]:
		var direction:=1.0 if corner.x<0 else -1.0
		draw_line(corner,corner+Vector2(20*direction,0),Color("745431"),2,true)
		draw_line(corner,corner+Vector2(0,9*direction),Color("745431"),2,true)
	var center:=Vector2(26,30)
	draw_arc(center,20,0,TAU,64,Color(.85,.76,.56,.22),1,true)
	draw_arc(center,20,phase*1.4,phase*1.4+PI*.75,32,ink,1.5,true)
	for i in range(3):
		var x:float=17+i*7
		var h:float=13+i%2*7
		draw_line(Vector2(x,37),Vector2(x,37-h),ink,3,true)
	var font:=ThemeDB.fallback_font
	draw_string(font,Vector2(62,27),"БОЛЬШОЙ ОБХОД",HORIZONTAL_ALIGNMENT_LEFT,-1,19,ink)
	draw_string(font,Vector2(62,46),"ЛЕНСКИЕ СТОЛБЫ",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("59432b"))
	draw_line(Vector2(0,67),Vector2(size.x,67),Color("a99061"),2,true)
	if progress>0:draw_line(Vector2(0,67),Vector2(size.x*clampf(progress/100,0,1),67),Color("745431"),3,true)
	draw_string(font,Vector2(size.x-60,37),"%02d" % int(progress),HORIZONTAL_ALIGNMENT_RIGHT,60,24,ink)
