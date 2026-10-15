extends Control
var photo_path:=""
var caption:=""
var zoom:=1.0
var image_view:TextureRect
var photo_area:Control
var pan:=Vector2.ZERO
var dragging:=false
var zoom_tween:Tween
var title:Label
var hint:Label
var close:Button
var photo_frame:Panel
func _ready() -> void:
	name="PhotoLightbox"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index=100
	var veil:=ColorRect.new()
	veil.color=Color("d7bf91")
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(veil)
	var image:=Image.new()
	if image.load(photo_path)!=OK:queue_free();return
	image_view=TextureRect.new()
	image_view.texture=ImageTexture.create_from_image(image)
	image_view.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	image_view.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image_view.mouse_filter=Control.MOUSE_FILTER_IGNORE
	photo_frame=Panel.new()
	photo_frame.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var frame_style:=StyleBoxFlat.new()
	frame_style.bg_color=Color("302e2a")
	frame_style.border_color=Color("877357")
	frame_style.set_border_width_all(2)
	photo_frame.add_theme_stylebox_override("panel",frame_style)
	add_child(photo_frame)
	photo_area=Control.new()
	photo_area.clip_contents=true
	add_child(photo_area)
	photo_area.add_child(image_view)
	title=Label.new()
	title.name="PhotoTitle"
	title.text=caption
	title.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	title.tooltip_text=caption
	title.mouse_filter=Control.MOUSE_FILTER_PASS
	title.add_theme_font_size_override("font_size",22)
	title.add_theme_color_override("font_color",Color("30271c"))
	add_child(title)
	hint=Label.new()
	hint.name="PhotoHint"
	# Set the footer width before its first minimum-size pass.
	hint.size=Vector2(maxf(1,size.x-64),38)
	hint.text="КОЛЕСО · МАСШТАБ   ПЕРЕТАЩИТЬ · ОБЗОР   ДВОЙНОЙ ЩЕЛЧОК · СБРОС   ESC · НАЗАД"
	hint.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	hint.tooltip_text=hint.text
	hint.mouse_filter=Control.MOUSE_FILTER_PASS
	hint.add_theme_font_size_override("font_size",12)
	hint.add_theme_color_override("font_color",Color("30271c"))
	add_child(hint)
	close=Button.new()
	close.name="PhotoClose"
	close.text="✕"
	close.tooltip_text="Закрыть фото (Esc)"
	close.size=Vector2(55,40)
	close.theme=preload("res://scripts/ui_theme.gd").make_theme()
	add_child(close)
	close.pressed.connect(queue_free)
	resized.connect(layout_viewer)
	layout_viewer()
	modulate.a=0
	create_tween().tween_property(self,"modulate:a",1.0,.22)
func layout_viewer() -> void:
	if not is_instance_valid(photo_area):return
	# Retain the established 1160 x 580 area at 1280 x 720; smaller
	# windows reserve the same readable header/footer rather than scaling text.
	var outer_margin:=clampf(size.x*.025,16,32)
	var photo_margin:=clampf(size.x*60.0/1280.0,24,60)
	var photo_top:=70.0
	var photo_bottom:=70.0
	photo_area.position=Vector2(photo_margin,photo_top)
	photo_area.size=Vector2(maxf(1,size.x-photo_margin*2),maxf(1,size.y-photo_top-photo_bottom))
	photo_frame.position=photo_area.position-Vector2(2,2)
	photo_frame.size=photo_area.size+Vector2(4,4)
	close.position=Vector2(size.x-outer_margin-3-close.size.x,15)
	title.position=Vector2(outer_margin,20)
	title.size=Vector2(maxf(1,close.position.x-outer_margin-16),32)
	hint.position=Vector2(outer_margin,photo_area.position.y+photo_area.size.y+16)
	hint.size=Vector2(maxf(1,size.x-outer_margin*2),38)
	layout_photo()
func layout_photo() -> void:
	if not is_instance_valid(image_view):return
	var extent:=photo_area.size*zoom
	var limit:Vector2=(extent-photo_area.size)*.5
	pan=pan.clamp(-limit,limit)
	image_view.position=(photo_area.size-extent)*.5+pan
	image_view.size=extent
func set_zoom(value:float) -> void:
	if is_instance_valid(zoom_tween):zoom_tween.kill()
	zoom_tween=create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	zoom_tween.tween_method(func(amount:float):zoom=amount;layout_photo(),zoom,clampf(value,1,2.5),.18)
func _input(event:InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		queue_free()
	elif event is InputEventMouseButton:
		if event.button_index==MOUSE_BUTTON_LEFT:
			dragging=event.pressed and photo_area.get_global_rect().has_point(get_global_mouse_position())
			if event.double_click and dragging:pan=Vector2.ZERO;set_zoom(1)
		elif event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			set_zoom(zoom+(.25 if event.button_index==MOUSE_BUTTON_WHEEL_UP else -.25))
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and dragging:
		pan+=event.relative
		layout_photo()
		get_viewport().set_input_as_handled()
