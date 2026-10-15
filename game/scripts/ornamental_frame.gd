extends Control
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	call_deferred("attach_outer_frame")
func attach_outer_frame() -> void:
	# A PanelContainer lays direct Control children inside its content margins.
	# Draw in a non-container layer so ornament stays on the outer panel rim.
	var panel:=get_parent() as Control
	if panel is Container:
		var layer:=Node2D.new()
		panel.add_child(layer)
		reparent(layer)
		position=Vector2(10,10)
		size=panel.size-Vector2(20,20)
		panel.resized.connect(func():size=panel.size-Vector2(20,20))
	else:set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
func _draw() -> void:
	var gold:=Color("b6a071")
	var dark:=Color(.01,.035,.025,.7)
	var s:=size
	for corner in [Vector2(0,0),Vector2(s.x,0),Vector2(0,s.y),s]:
		var sign:=Vector2(1 if corner.x==0 else -1,1 if corner.y==0 else -1)
		var p:Vector2=corner+sign*Vector2(5,5)
		draw_line(p+sign*Vector2(1,2),p+sign*Vector2(29,2),dark,4,true)
		draw_line(p,p+sign*Vector2(25,0),gold,2,true)
		draw_line(p,p+sign*Vector2(0,19),gold,2,true)
		draw_circle(p+sign*Vector2(5,5),1.7,Color("f2d39a"))
	draw_line(Vector2(38,2),Vector2(s.x-38,2),Color(.9,.82,.65,.15),1,true)
	draw_line(Vector2(16,s.y-3),Vector2(s.x-16,s.y-3),dark,3,true)
	var mid:=s.x*.5
	draw_colored_polygon(PackedVector2Array([Vector2(mid-5,2),Vector2(mid,6),Vector2(mid+5,2),Vector2(mid,-2)]),gold)
