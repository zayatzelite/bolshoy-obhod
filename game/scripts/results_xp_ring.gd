extends Control
var xp:=0
var level:=1
var fill:=0.0
var earned:=0
var displayed_xp:=0.0
func _ready() -> void:
	custom_minimum_size=Vector2(190,190)
	displayed_xp=float(maxi(0,xp-earned))
	update_display(displayed_xp)
	var tween:=create_tween()
	tween.tween_method(update_display,displayed_xp,float(xp),2.0).set_trans(Tween.TRANS_LINEAR)
func update_display(value: float) -> void:
	displayed_xp=value
	var whole:=int(value)
	level=1+int(whole/100)
	fill=float(whole%100)/100.0
	queue_redraw()
func _draw() -> void:
	var center:=size*.5
	draw_circle(center,76,Color("d7bf91"))
	draw_arc(center,82,-PI/2,TAU-PI/2,96,Color("776b4b"),8,true)
	if fill>0:draw_arc(center,82,-PI/2,-PI/2+TAU*fill,96,Color("e8c875"),8,true)
	draw_string(ThemeDB.fallback_font,center+Vector2(-54,-24),"УРОВЕНЬ",HORIZONTAL_ALIGNMENT_CENTER,108,17,Color("30271c"))
	draw_string(ThemeDB.fallback_font,center+Vector2(-54,18),str(level),HORIZONTAL_ALIGNMENT_CENTER,108,40,Color("30271c"))
	draw_string(ThemeDB.fallback_font,center+Vector2(-65,48),"%d / 100 XP" % (int(displayed_xp)%100),HORIZONTAL_ALIGNMENT_CENTER,130,15,Color("30271c"))
