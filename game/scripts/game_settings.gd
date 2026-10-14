extends RefCounted

const PATH := "user://settings.cfg"
const DEFAULTS := {"volume": 80.0, "fullscreen": false, "vsync": true, "sensitivity": 0.0025, "invert_y": false, "fov": 78.0, "shadows": true, "msaa": true, "bob": false}

static func read_values() -> Dictionary:
	var file := ConfigFile.new()
	file.load(PATH)
	var values := DEFAULTS.duplicate()
	for key in values:
		values[key] = file.get_value("game", key, values[key])
	return sanitize(values)

static func sanitize(input: Dictionary) -> Dictionary:
	var values := DEFAULTS.duplicate()
	for key in DEFAULTS:
		var value = input.get(key,DEFAULTS[key])
		if DEFAULTS[key] is bool:
			if value is bool:values[key] = value
		elif value is float or value is int:
			if is_finite(float(value)):values[key] = float(value)
	values.volume = clampf(values.volume,0,100)
	values.sensitivity = clampf(values.sensitivity,.0005,.006)
	values.fov = clampf(values.fov,60,100)
	return values

static func save_values(values: Dictionary) -> Error:
	var file := ConfigFile.new()
	for key in values:
		file.set_value("game", key, values[key])
	return file.save(PATH)

static func apply(values: Dictionary, viewport: Viewport) -> void:
	AudioServer.set_bus_volume_linear(0, float(values.volume) / 100.0)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if values.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if values.vsync else DisplayServer.VSYNC_DISABLED)
	viewport.msaa_3d = Viewport.MSAA_4X if values.msaa else Viewport.MSAA_DISABLED

static func make_panel(parent: Node, on_close: Callable) -> PanelContainer:
	var values := read_values()
	var panel := PanelContainer.new()
	panel.set_meta("fullscreen_screen",true)
	panel.custom_minimum_size = Vector2(1280,720)
	panel.theme = preload("res://scripts/ui_theme.gd").make_theme()
	var style := preload("res://scripts/ui_theme.gd").panel_style()
	style.bg_color = Color("302c23")
	style.set_content_margin_all(48)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	var layout := VBoxContainer.new()
	panel.add_child(layout)
	var title := Label.new()
	title.text = "НАСТРОЙКИ"
	title.add_theme_font_size_override("font_size",32)
	layout.add_child(title)
	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(tabs)
	var groups := {}
	for section in ["Графика","Управление","Звук"]:
		var scroll := ScrollContainer.new()
		scroll.name = section
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		tabs.add_child(scroll)
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_theme_constant_override("separation",20)
		scroll.add_child(column)
		groups[section] = column
	for entry in [["volume", "Громкость", 0.0, 100.0, 1.0], ["sensitivity", "Чувствительность мыши", 0.0005, 0.006, 0.0001], ["fov", "Поле зрения", 60.0, 100.0, 1.0]]:
		var key: String = entry[0]
		var column: VBoxContainer = groups["Звук" if key=="volume" else "Управление"]
		var caption := Label.new()
		caption.text = "%s · %.4f" % [entry[1],float(values[key])] if key=="sensitivity" else "%s · %d" % [entry[1],int(values[key])]
		caption.add_theme_color_override("font_color", Color("f3e8cb"))
		column.add_child(caption)
		var slider := HSlider.new()
		slider.min_value = entry[2]
		slider.max_value = entry[3]
		slider.step = entry[4]
		slider.value = values[key]
		column.add_child(slider)
		slider.value_changed.connect(func(value: float) -> void:
			values[key] = value
			caption.text = "%s · %.4f" % [entry[1],value] if key=="sensitivity" else "%s · %d" % [entry[1],int(value)]
			save_values(values)
			apply(values, parent.get_viewport()))
	for entry in [["fullscreen", "Полноэкранный режим"], ["vsync", "Вертикальная синхронизация"], ["shadows", "Тени"], ["msaa", "Сглаживание 4×"], ["invert_y", "Инверсия мыши по вертикали"], ["bob", "Покачивание камеры"]]:
		var key: String = entry[0]
		var column: VBoxContainer = groups["Управление" if key in ["invert_y","bob"] else "Графика"]
		var toggle := CheckButton.new()
		toggle.text = entry[1]
		toggle.button_pressed = values[key]
		for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
			toggle.add_theme_color_override(color_name, Color("f3e8cb"))
		column.add_child(toggle)
		toggle.toggled.connect(func(value: bool) -> void:
			values[key] = value
			save_values(values)
			apply(values, parent.get_viewport()))
	var help := Label.new()
	help.text = "WASD — ходьба · Shift — бег · Пробел — прыжок\nE — действие · I — рюкзак · R — убрать / достать\n1–3 — выбрать предмет из рюкзака · G — положить\nM — схема маршрута · Tab — навыки и журнал · Esc — пауза"
	help.add_theme_font_size_override("font_size", 14)
	help.add_theme_color_override("font_color", Color("c3c4a8"))
	groups["Управление"].add_child(help)
	var audio_note := Label.new()
	audio_note.text = "Аудиоматериалы ещё не подключены."
	groups["Звук"].add_child(audio_note)
	var close := Button.new()
	close.text = "Сохранено · Вернуться"
	close.custom_minimum_size.y = 42
	layout.add_child(close)
	close.pressed.connect(func() -> void:
		panel.queue_free()
		on_close.call())
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preload("res://scripts/ui_theme.gd").skin_buttons(panel)
	return panel
