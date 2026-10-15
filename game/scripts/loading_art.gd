extends Control
var phase:=0.0
var cinematic: Texture2D
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if ResourceLoader.exists("res://assets/ui/loading_lena.png"):
		cinematic=load("res://assets/ui/loading_lena.png")
		var shade:=ColorRect.new()
		shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		shade.mouse_filter=Control.MOUSE_FILTER_IGNORE
		var mat:=ShaderMaterial.new()
		mat.shader=preload("res://shaders/loading_shade.gdshader")
		shade.material=mat
		add_child(shade)
func _process(delta:float) -> void:
	phase+=delta
	queue_redraw()
func _draw() -> void:
	var s:=size
	if cinematic:
		var ratio:=maxf(s.x/cinematic.get_width(),s.y/cinematic.get_height())
		var extent:=cinematic.get_size()*ratio
		draw_texture_rect(cinematic,Rect2((s-extent)*.5,extent),false)
		return
	draw_rect(Rect2(Vector2.ZERO,s),Color("183c42"))
	for i in range(60):
		var t:=float(i)/60
		draw_rect(Rect2(0,s.y*t,s.x,s.y/60+1),Color("244b50").lerp(Color("c7a275"),t))
	draw_circle(Vector2(s.x*.76,s.y*.23),s.y*.075,Color("e2c795"))
	for layer in range(2):
		var points:=PackedVector2Array([Vector2(0,s.y*.69)])
		for i in range(31):
			var x:=s.x*i/30.0
			points.append(Vector2(x,s.y*(.56+.05*sin(i*.47+layer))))
		points.append(Vector2(s.x,s.y));points.append(Vector2(0,s.y))
		draw_colored_polygon(points,Color("547269") if layer==0 else Color("34594f"))
	for i in range(15):
		var x:float=s.x*(.55+i*.031)
		var h:float=s.y*(.12+.13*absf(sin(i*2.31)))
		var base:float=s.y*.61
		var width:float=s.x*.024
		var rock:=PackedVector2Array([Vector2(x-width*.5,base),Vector2(x-width*.44,base-h*.71),Vector2(x-width*.24,base-h),Vector2(x+width*.2,base-h*1.04),Vector2(x+width*.38,base-h*.7),Vector2(x+width*.5,base)])
		draw_colored_polygon(rock,Color("b9a780").lerp(Color("7a8270"),float(i%3)/4))
		draw_line(Vector2(x,base-h*.92),Vector2(x+width*.1,base),Color(.3,.36,.3,.3),2,true)
	draw_colored_polygon(PackedVector2Array([Vector2(0,s.y*.72),Vector2(s.x*.58,s.y*.62),Vector2(s.x,s.y*.65),s,Vector2(0,s.y)]),Color("36636b"))
	for i in range(24):
		var y:float=s.y*(.67+i*.011)
		var x:float=s.x*(.48+.11*sin(i*1.8+phase*.12))
		draw_line(Vector2(x,y),Vector2(x+s.x*(.10+i*.006),y),Color(.8,.78,.58,.1),1,true)
	for i in range(12):
		var x:float=s.x*(i*.028)
		var h:float=s.y*(.13+.12*absf(sin(i*1.7)))
		var base:float=s.y*.8
		draw_line(Vector2(x,base-h),Vector2(x,base+30),Color("172f2b"),5,true)
		for j in range(3):
			var top:float=base-h+j*h*.2
			var w:float=h*(.2+j*.055)
			draw_colored_polygon(PackedVector2Array([Vector2(x,top),Vector2(x-w,top+h*.42),Vector2(x+w,top+h*.42)]),Color("204137"))
	for i in range(4):
		var x:float=fposmod(s.x*(.08+i*.24)+phase*3,s.x+160)-80
		var y:float=s.y*(.16+.035*sin(i*2))
		draw_circle(Vector2(x,y),25,Color(.86,.89,.79,.12))
		draw_circle(Vector2(x+32,y+5),32,Color(.86,.89,.79,.12))
	draw_rect(Rect2(0,s.y*.47,s.x,s.y*.53),Color(.025,.06,.055,.55))
	draw_string(ThemeDB.fallback_font,Vector2(48,52),"ЛЕНСКИЕ СТОЛБЫ  /  ПОЛЕВОЙ ДНЕВНИК",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("ead6b0"))
