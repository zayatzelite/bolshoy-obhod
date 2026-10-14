extends RefCounted

static func make_panel(parent: Node, record: Dictionary, on_close: Callable) -> PanelContainer:
	if record.is_empty():return null
	var panel := PanelContainer.new()
	panel.theme = preload("res://scripts/ui_theme.gd").make_theme()
	var style := preload("res://scripts/ui_theme.gd").panel_style()
	style.bg_color = Color("302c23")
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
	latin.add_theme_color_override("font_color",Color("d8ba77"))
	layout.add_child(latin)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(712,360)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)
	var contents := VBoxContainer.new()
	contents.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contents.add_theme_constant_override("separation",12)
	scroll.add_child(contents)
	var photo := TextureRect.new()
	photo.texture = load(str(record.photo)) as Texture2D
	photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	photo.custom_minimum_size = Vector2(0,180)
	contents.add_child(photo)
	for entry in [["О РАСТЕНИИ","description"],["МЕСТООБИТАНИЕ","habitat"],["КАК СОХРАНИТЬ","protection"],["ИСТОЧНИК","source"]]:
		var label := Label.new()
		label.text = "%s\n%s" % [entry[0],record.get(entry[1],"")]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		contents.add_child(label)
	var close := Button.new()
	close.text = "Вернуться"
	close.custom_minimum_size.y = 48
	layout.add_child(close)
	close.pressed.connect(func() -> void:
		panel.queue_free()
		on_close.call())
	return panel
