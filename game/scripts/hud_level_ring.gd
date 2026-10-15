extends Control
var xp:=0
var shown:=0.0
var initialized:=false
func _ready() -> void:mouse_filter=Control.MOUSE_FILTER_IGNORE
func set_xp(value: int) -> void:
	xp=maxi(0,value)
	if not initialized:shown=xp;initialized=true;queue_redraw()
func _process(delta: float) -> void:
	if absf(shown-xp)>.01:
		shown=move_toward(shown,float(xp),maxf(80,absf(shown-xp)*3)*delta)
		queue_redraw()
func _draw() -> void:
	var c:=size*.5
	draw_circle(c,51,Color(.84,.72,.51,.98))
	draw_arc(c,50,0,TAU,96,Color("796d51"),1.5,true)
	for i in range(20):
		var angle:float=i*TAU/20-PI/2
		draw_line(c+Vector2.from_angle(angle)*44,c+Vector2.from_angle(angle)*47,Color("948465"),1,true)
	var fraction:=float(int(shown)%100)/100.0
	draw_arc(c,40,-PI/2,TAU-PI/2,96,Color("403f30"),4,true)
	if fraction>0:draw_arc(c,40,-PI/2,-PI/2+TAU*fraction,96,Color("e8c875"),4,true)
	var font:=ThemeDB.fallback_font
	draw_string(font,c+Vector2(-35,-13),"УРОВЕНЬ",HORIZONTAL_ALIGNMENT_CENTER,70,10,Color("30271c"))
	draw_string(font,c+Vector2(-35,15),str(1+int(shown)/100),HORIZONTAL_ALIGNMENT_CENTER,70,30,Color("30271c"))
	draw_string(font,c+Vector2(-35,30),"%d XP" % (int(shown)%100),HORIZONTAL_ALIGNMENT_CENTER,70,10,Color("59432b"))
