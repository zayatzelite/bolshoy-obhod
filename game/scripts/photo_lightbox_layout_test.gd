extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	# Exercise the same Node2D parent used by world without loading world,
	# rendering, creating photo files, or touching persistent progress.
	var host:=Node2D.new()
	root.add_child(host)
	var viewer=load("res://scripts/photo_lightbox.gd").new()
	viewer.photo_path="res://assets/menu/background.png"
	viewer.caption="Очень длинная подпись фотографии растения на светлом берегу — ".repeat(8)
	host.add_child(viewer)
	viewer.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	viewer.size=Vector2(1280,720)
	await process_frame
	assert(viewer.photo_area.size==Vector2(1160,580))
	check_bounds(viewer)
	viewer.zoom=2.0
	viewer.pan=Vector2(9999,-9999)
	viewer.layout_photo()
	assert(viewer.pan==Vector2(580,-290))
	viewer.size=Vector2(960,540)
	await process_frame
	assert(viewer.photo_area.size==Vector2(870,400))
	assert(viewer.zoom==2.0)
	assert(viewer.pan==Vector2(435,-200))
	check_bounds(viewer)
	assert(viewer.title.text_overrun_behavior==TextServer.OVERRUN_TRIM_ELLIPSIS)
	assert(viewer.title.tooltip_text==viewer.caption)
	assert(viewer.hint.get_line_count()==1)
	var hint_font:Font=viewer.hint.get_theme_font("font")
	assert(hint_font.get_string_size(viewer.hint.text,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x<=viewer.hint.size.x,"Full hint must fit at 960 without ellipsis")
	assert(viewer.hint.get_minimum_size().y<=viewer.hint.size.y)
	assert(viewer.title.get_theme_color("font_color")==Color("30271c"))
	assert(viewer.hint.get_theme_color("font_color")==Color("30271c"))
	viewer.set_zoom(1.0)
	await create_timer(.25).timeout
	assert(is_equal_approx(viewer.zoom,1.0) and viewer.pan==Vector2.ZERO)
	assert(viewer.image_view.size==viewer.photo_area.size)
	viewer.size=Vector2(1280,720)
	await process_frame
	assert(viewer.photo_area.size==Vector2(1160,580))
	check_bounds(viewer)
	viewer.close.pressed.emit()
	await process_frame
	assert(not is_instance_valid(viewer))
	host.free()
	print("PHOTO LIGHTBOX LAYOUT PASS: 1280/960 bounds, title ellipsis, readable footer, preserved zoom, clamped pan, reset and close; no saves")
	quit()

func check_bounds(viewer:Control) -> void:
	var bounds:=Rect2(Vector2.ZERO,viewer.size)
	for control in [viewer.title,viewer.hint,viewer.close,viewer.photo_area,viewer.photo_frame]:
		assert(bounds.encloses(Rect2(control.position,control.size)),"Control out of bounds: %s" % control.name)
	assert(viewer.title.position.x+viewer.title.size.x+16<=viewer.close.position.x)
	assert(viewer.title.position.y+viewer.title.size.y<viewer.photo_area.position.y)
	assert(viewer.photo_area.position.y+viewer.photo_area.size.y<viewer.hint.position.y)
	assert(viewer.photo_area.clip_contents)
