extends Control
var blend:=0.0
var shots:=0
var subject := ""
var zoom := 1.0
var glass: ShaderMaterial
func _process(_delta:float) -> void:
	if glass:glass.set_shader_parameter("strength",blend)
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var pane:=ColorRect.new()
	pane.mouse_filter=Control.MOUSE_FILTER_IGNORE
	pane.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glass=ShaderMaterial.new()
	glass.shader=preload("res://shaders/viewfinder_glass.gdshader")
	pane.material=glass
	add_child(pane)
	pane.show_behind_parent=true
func _draw() -> void:
	if blend<=.01:return
	var ink:=Color(.94,.86,.68,blend)
	var shade:=Color(.055,.06,.065,.94*blend)
	var margin:=Vector2(size.x*.075,size.y*.10)
	var frame:=Rect2(margin,size-margin*2)
	# Rounded glass mask and vignette are drawn by the shader behind these markings.
	for side in [-1,1]:
		var x:float=size.x*.5+side*frame.size.x*.5
		draw_line(Vector2(x,size.y*.5-18),Vector2(x,size.y*.5+18),ink,2,true)
	var grid:=Color(.84,.73,.52,.14*blend)
	for i in [1,2]:
		var x:float=frame.position.x+frame.size.x*i/3.0
		var y:float=frame.position.y+frame.size.y*i/3.0
		draw_line(Vector2(x,frame.position.y),Vector2(x,frame.end.y),grid,1,true)
		draw_line(Vector2(frame.position.x,y),Vector2(frame.end.x,y),grid,1,true)
	var focus:=Rect2(size*.5-Vector2(62,62),Vector2(124,124))
	var focus_color:=Color(.94,.80,.49,.9*blend) if not subject.is_empty() else Color(.94,.86,.68,.6*blend)
	draw_arc(size*.5,54,0,TAU,80,focus_color,1.2,true)
	for corner in [focus.position,Vector2(focus.end.x,focus.position.y),focus.end,Vector2(focus.position.x,focus.end.y)]:
		var dx:float=1 if corner.x<size.x/2 else -1
		var dy:float=1 if corner.y<size.y/2 else -1
		draw_line(corner,corner+Vector2(12*dx,0),focus_color,1.5,true)
		draw_line(corner,corner+Vector2(0,12*dy),focus_color,1.5,true)
	draw_line(size*.5-Vector2(4,0),size*.5+Vector2(4,0),ink,1,true)
	draw_line(size*.5-Vector2(0,4),size*.5+Vector2(0,4),ink,1,true)
	for corner in [Vector2(24,24),Vector2(size.x-24,24),size-Vector2(24,24),Vector2(24,size.y-24)]:
		var dx:float=1 if corner.x<size.x/2 else -1
		var dy:float=1 if corner.y<size.y/2 else -1
		draw_line(corner,corner+Vector2(110*dx,0),Color(.84,.73,.52,.4*blend),1,true)
		draw_line(corner,corner+Vector2(0,90*dy),Color(.84,.73,.52,.4*blend),1,true)
	var font:=ThemeDB.fallback_font
	var focus_caption:=subject if not subject.is_empty() else "ВИД НЕ ОПРЕДЕЛЁН"
	# A compact badge protects plant names against pale sky and sunlit rock.
	# Only the caption gets a backing; the central landscape stays unobstructed.
	var caption_width:=minf(font.get_string_size(focus_caption,HORIZONTAL_ALIGNMENT_LEFT,-1,16).x,minf(400.0,size.x-64.0))
	var caption_baseline:=focus.end.y+24
	var caption_rect:=Rect2(Vector2(size.x*.5-caption_width*.5-12,caption_baseline-font.get_ascent(16)-7),Vector2(caption_width+24,font.get_height(16)+14))
	var caption_style:=StyleBoxFlat.new()
	caption_style.bg_color=shade
	caption_style.border_color=Color(.84,.73,.52,.55*blend)
	caption_style.set_border_width_all(1)
	caption_style.set_corner_radius_all(6)
	draw_style_box(caption_style,caption_rect)
	draw_string(font,Vector2(size.x*.5-caption_width*.5,caption_baseline),focus_caption,HORIZONTAL_ALIGNMENT_CENTER,caption_width,16,ink)
	draw_circle(Vector2(margin.x-16,margin.y*.60-7),3,Color(.75,.87,.63,blend))
	draw_string(font,Vector2(margin.x,margin.y*.60),"ОБХОД / ФОТО",HORIZONTAL_ALIGNMENT_LEFT,-1,20,ink)
	for i in range(21):
		var tick_x:float=size.x*.5+(i-10)*8
		var tick_h:float=10 if i%5==0 else 5
		draw_line(Vector2(tick_x,size.y-24),Vector2(tick_x,size.y-24-tick_h),ink,1,true)
	var zoom_indicator:float=size.x*.5+clampf((zoom-1)*120,-80,80)
	draw_colored_polygon(PackedVector2Array([Vector2(zoom_indicator,size.y-39),Vector2(zoom_indicator-3,size.y-44),Vector2(zoom_indicator+3,size.y-44)]),Color(.88,.76,.47,blend))
	draw_string(font,Vector2(size.x-margin.x-210,margin.y*.60),"СНИМКИ  %03d" % shots,HORIZONTAL_ALIGNMENT_RIGHT,210,18,ink)
	draw_string(font,Vector2(margin.x,size.y-margin.y*.40),"ПКМ — видоискатель    ЛКМ — снимок    C — убрать",HORIZONTAL_ALIGNMENT_LEFT,-1,17,ink)
	var dial:=Vector2(size.x-margin.x*.48,size.y*.70)
	draw_circle(dial,24,Color(.055,.06,.065,.72*blend))
	draw_arc(dial,24,-PI/2,PI*1.2,48,Color(.88,.76,.47,blend),2,true)
	for i in range(8):
		var angle:float=i*TAU/8
		draw_line(dial+Vector2.from_angle(angle)*18,dial+Vector2.from_angle(angle)*21,ink,1,true)
	draw_circle(dial,7,Color(.94,.86,.68,blend),false,1.5,true)
	draw_string(font,Vector2(dial.x-36,dial.y+43),"ОБЪЕКТИВ",HORIZONTAL_ALIGNMENT_CENTER,72,10,ink)
	draw_string(font,Vector2(size.x-margin.x-160,size.y-margin.y*.40),"ФОТОРЕЖИМ",HORIZONTAL_ALIGNMENT_RIGHT,160,16,ink)
