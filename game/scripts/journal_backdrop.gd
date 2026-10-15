extends Control
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
var book_spread:=false
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("d7bf91"))
	if book_spread:
		var page_top:=118.0
		var page_bottom:=size.y-76
		for side in range(2):
			var page:=Rect2(Vector2(14+side*(size.x*.5),page_top),Vector2(size.x*.5-28,page_bottom-page_top))
			draw_rect(Rect2(page.position+Vector2(2,5),page.size),Color(.24,.15,.08,.16))
			draw_rect(page,Color("e5cca0"))
			draw_rect(page.grow(-5),Color(.42,.29,.14,.3),false,1)
		for line in range(16):
			var x:=size.x*.5-8+line
			draw_line(Vector2(x,page_top+5),Vector2(x,page_bottom),Color(.28,.17,.08,.12*(1-absf(line-7.5)/8)),1)
		for stitch in range(10):
			var y:=page_top+20+stitch*(page_bottom-page_top-40)/9
			draw_line(Vector2(size.x*.5-4,y),Vector2(size.x*.5+4,y+2),Color(.39,.27,.13,.4),1,true)
	for x in range(0,int(size.x),48):draw_line(Vector2(x,0),Vector2(x,size.y),Color(.5,.65,.56,.028),1)
	for y in range(0,int(size.y),48):draw_line(Vector2(0,y),Vector2(size.x,y),Color(.5,.65,.56,.028),1)
	var center:=Vector2(size.x-190,size.y-210)
	for r in [120,145,150]:draw_arc(center,r,0,TAU,96,Color(.7,.65,.45,.045),1,true)
	for tick in range(48):
		var direction:=Vector2.from_angle(tick*TAU/48)
		draw_line(center+direction*150,center+direction*(157 if tick%4==0 else 153),Color(.7,.65,.45,.06),1,true)
