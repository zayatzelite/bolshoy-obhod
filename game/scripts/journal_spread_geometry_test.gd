extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	# Read-only geometry prototype for the 1280 journal. No world instance,
	# persistent state, images, GPU capture, or GUI required.
	var host:=Control.new()
	host.size=Vector2(1280,720)
	root.add_child(host)
	var photos:=GridContainer.new()
	photos.columns=2
	photos.position=Vector2(24,180)
	photos.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
	photos.add_theme_constant_override("h_separation",72)
	photos.add_theme_constant_override("v_separation",16)
	host.add_child(photos)
	for i in range(6):
		var card:=VBoxContainer.new()
		card.custom_minimum_size.x=568
		photos.add_child(card)
		var frame:=PanelContainer.new()
		var style:=StyleBoxFlat.new()
		style.set_content_margin_all(10)
		frame.add_theme_stylebox_override("panel",style)
		card.add_child(frame)
		var preview:=TextureRect.new()
		preview.custom_minimum_size=Vector2(548,308)
		preview.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		frame.add_child(preview)
		var caption:=Label.new()
		caption.text="Пейзаж · вид не определён"
		caption.custom_minimum_size.x=548
		caption.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		card.add_child(caption)
		var stamp:=Label.new()
		stamp.text="КАДР %02d · 2026-10-15T08:30:00" % i
		stamp.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		stamp.add_theme_font_size_override("font_size",11)
		card.add_child(stamp)
	var species:=GridContainer.new()
	species.columns=4
	species.position=Vector2(24,180)
	species.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
	species.add_theme_constant_override("h_separation",64)
	species.add_theme_constant_override("v_separation",16)
	host.add_child(species)
	for i in range(21):
		var record:=Button.new()
		record.custom_minimum_size=Vector2(256,200)
		species.add_child(record)
		var art:=TextureRect.new()
		art.position=Vector2(8,8)
		art.size=Vector2(240,135)
		art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		record.add_child(art)
		var label:=Label.new()
		label.text="Длинное название растения\n○ НЕ ОТМЕЧЕН"
		label.position=Vector2(12,145)
		label.size=Vector2(232,50)
		label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size",13)
		record.add_child(label)
	await process_frame
	await process_frame
	assert(photos.size.x==1208)
	assert(species.size.x==1216)
	check_pages(photos)
	check_pages(species)
	for i in range(photos.get_child_count()):
		assert(photos.get_child(i).get_global_rect().position.x==24+640*(i%2))
	for i in range(species.get_child_count()):
		assert(species.get_child(i).get_global_rect().position.x==24+320*(i%4))
	host.free()
	print("JOURNAL SPREAD GEOMETRY PASS: photo568+gutter72 and species256+gaps64 stay on separate pages; no world changes or saves")
	quit()

func check_pages(grid:GridContainer) -> void:
	for child in grid.get_children():
		var rect:Rect2=child.get_global_rect()
		assert(rect.position.x>=24 and rect.end.x<=1240,"Card exceeds page outside bounds")
		assert(rect.end.x<=626 or rect.position.x>=654,"Card crosses book spine")
