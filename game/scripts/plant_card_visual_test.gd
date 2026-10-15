extends SceneTree
func _initialize() -> void:call_deferred("run")
func check_record(panel:PanelContainer,record:Dictionary) -> void:
	for field in ["description","habitat","protection"]:
		var body:Label=panel.find_child("Record_"+field,true,false)
		assert(is_instance_valid(body),"Missing visible record field: "+field)
		assert(body.text==str(record[field]).strip_edges(),"Body must show actual catalog text: "+field)
		assert(body.autowrap_mode==TextServer.AUTOWRAP_WORD_SMART)
		assert(body.is_visible_in_tree())
	var frame:PanelContainer=panel.find_child("SpecimenFrame",true,false)
	assert(frame.get_theme_stylebox("panel").bg_color==Color("efdfbd"))
	var rect:=panel.get_global_rect()
	assert(rect.position.x>=0 and rect.position.y>=0 and rect.end.x<=1280 and rect.end.y<=720)
func run() -> void:
	root.content_scale_size=Vector2i(1280,720)
	root.size=Vector2i(1280,720)
	var host:=Control.new()
	root.add_child(host)
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var parsed:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/plants.json"))
	var records:Array=parsed.species
	assert(not records.is_empty())
	for record in records:
		var panel:=preload("res://scripts/plant_card.gd").make_panel(host,record,func():pass)
		await process_frame
		await process_frame
		if record==records[0] and DisplayServer.get_name()!="headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("C:/Users/zayatz/Downloads/lenskiy stolbi/plant_card_visual_preview.png")
		check_record(panel,record)
		var link:LinkButton=panel.find_child("RecordSource",true,false)
		assert(is_instance_valid(link) and link.uri==record.source)
		assert(panel.find_child("IllustrationDisclaimer",true,false).text.contains("НЕ БОТАНИЧЕСКИЙ ОПРЕДЕЛИТЕЛЬ"))
		if record==records[0] and DisplayServer.get_name()!="headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://../plant_card_visual_preview.png")
		panel.queue_free()
		await process_frame
	# UI fixtures only; these values are not persisted or added to the plant catalog.
	var fixture:Dictionary=records[0].duplicate(true)
	fixture.description="Проверка длинного текста, не ботанические сведения. ".repeat(24)
	fixture.source="javascript:alert('not a web source')"
	var closed:={"value":false}
	var panel:=preload("res://scripts/plant_card.gd").make_panel(host,fixture,func():closed.value=true)
	await process_frame
	await process_frame
	check_record(panel,fixture)
	assert(panel.find_child("RecordSource",true,false) is Label,"Only http(s) sources may become links")
	var scroll:ScrollContainer=panel.get_child(0).get_child(2)
	assert(scroll.get_v_scroll_bar().max_value>scroll.size.y,"Long descriptions must scroll, not clip")
	panel.get_child(0).get_child(3).pressed.emit()
	assert(closed.value,"Return callback must run")
	await process_frame
	host.queue_free()
	await process_frame
	print("PLANT CARD VISUAL PASS: %d catalog records, visible actual fields, paper frame, safe source links and scrollable long copy; no scientific validation" % records.size())
	quit()
