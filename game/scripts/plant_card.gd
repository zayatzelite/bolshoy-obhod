extends RefCounted

static func make_panel(parent: Node, record: Dictionary, on_close: Callable) -> PanelContainer:
	if record.is_empty():return null
	var panel := PanelContainer.new()
	panel.theme = preload("res://scripts/ui_theme.gd").make_theme()
	var style := preload("res://scripts/ui_theme.gd").panel_style()
	style.bg_color = Color("d7bf91")
	panel.add_theme_stylebox_override("panel",style)
	parent.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation",12)
	panel.add_child(layout)
	var title := Label.new()
	title.text = str(record.name_ru)
	title.add_theme_font_size_override("font_size",25)
	layout.add_child(title)
	var latin := Label.new()
	latin.text = str(record.name_latin)
	latin.add_theme_color_override("font_color",Color("654526"))
	layout.add_child(latin)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(712,360)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)
	var spread:=HBoxContainer.new()
	spread.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	spread.add_theme_constant_override("separation",28)
	scroll.add_child(spread)
	var specimen:=VBoxContainer.new()
	specimen.custom_minimum_size.x=420
	spread.add_child(specimen)
	var frame:=PanelContainer.new()
	frame.name="SpecimenFrame"
	var backing:=StyleBoxFlat.new()
	backing.bg_color=Color("efdfbd")
	backing.border_color=Color("654526")
	backing.set_border_width_all(1)
	backing.set_content_margin_all(18)
	backing.shadow_color=Color(0,0,0,.35)
	backing.shadow_size=6
	frame.add_theme_stylebox_override("panel",backing)
	specimen.add_child(frame)
	var contents := VBoxContainer.new()
	contents.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contents.add_theme_constant_override("separation",18)
	spread.add_child(contents)
	var photo := TextureRect.new()
	photo.texture = load(str(record.photo)) as Texture2D
	photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	photo.custom_minimum_size = Vector2(360,340)
	frame.add_child(photo)
	frame.add_child(preload("res://scripts/ornamental_frame.gd").new())
	if record.has("image_kind"):
		var image_note:=Label.new()
		image_note.name="IllustrationDisclaimer"
		image_note.text="СТИЛИЗОВАННАЯ ИЛЛЮСТРАЦИЯ\nНЕ БОТАНИЧЕСКИЙ ОПРЕДЕЛИТЕЛЬ"
		image_note.tooltip_text=str(record.image_kind)
		image_note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		image_note.add_theme_font_size_override("font_size",13)
		specimen.add_child(image_note)
	for entry in [["О ЗАПИСИ","description"],["В ПАРКЕ И НА МАРШРУТЕ","habitat"],["НАБЛЮДАЙТЕ, НЕ СРЫВАЙТЕ","protection"]]:
		var heading:=Label.new()
		heading.text=entry[0]
		heading.add_theme_font_size_override("font_size",12)
		heading.add_theme_color_override("font_color",Color("654526"))
		contents.add_child(heading)
		var label := Label.new()
		label.name="Record_"+entry[1]
		label.text=str(record.get(entry[1],"")).strip_edges()
		if label.text.is_empty():label.text="Сведения в этой записи не указаны."
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size",16)
		contents.add_child(label)
	var source:=str(record.get("source","")).strip_edges()
	if source.to_lower().begins_with("https://") or source.to_lower().begins_with("http://"):
		var link:=LinkButton.new()
		link.name="RecordSource"
		link.text="Первоисточник · открыть в браузере ↗"
		link.uri=source
		link.tooltip_text=source
		for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
			link.add_theme_color_override(state,Color("59432b"))
		link.add_theme_font_size_override("font_size",15)
		contents.add_child(link)
	else:
		var note:=Label.new()
		note.name="RecordSource"
		note.text="Источник: "+source if not source.is_empty() else "Источник в этой записи не указан."
		note.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		note.add_theme_font_size_override("font_size",15)
		contents.add_child(note)
	var close := Button.new()
	close.text = "Вернуться"
	close.custom_minimum_size.y = 48
	layout.add_child(close)
	close.pressed.connect(func() -> void:
		panel.queue_free()
		on_close.call())
	return panel
