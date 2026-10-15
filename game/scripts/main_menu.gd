extends Control

const SAVE_PATH := "user://settings.cfg"
var config := ConfigFile.new()
var modal: PanelContainer
var modal_body: VBoxContainer
var menu_buttons: Array[Button] = []
var status: Label

func _ready() -> void:
	config.load(SAVE_PATH)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	preload("res://scripts/game_settings.gd").apply(preload("res://scripts/game_settings.gd").read_values(), get_viewport())
	var art := TextureRect.new()
	art.texture = load("res://assets/menu/background.png")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)
	art.set_process(config.get_value("display", "animation", true))
	var shade := ColorRect.new()
	shade.color = Color(0.04, 0.15, 0.16, 0.025)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var panel := PanelContainer.new()
	panel.position = Vector2(32, 250)
	panel.size = Vector2(310, 390)
	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	var start := button(column, "Продолжить   →", show_start, true)
	start.disabled=not FileAccess.file_exists("user://progress.cfg")
	start.get_meta("button_material").set_shader_parameter("disabled",start.disabled)
	menu_buttons.append(start)
	menu_buttons.append(button(column,"Новая игра",show_new_game))
	var patrol := button(column, "Патрули", show_patrol)
	menu_buttons.append(patrol)
	menu_buttons.append(button(column, "Настройки", show_settings))
	menu_buttons.append(button(column, "Об игре", show_about))
	menu_buttons.append(button(column, "Выход", show_quit))
	status = label(column, "", 12, Color("a7c7b4"))
	modal = PanelContainer.new()
	modal.position = Vector2(565, 125)
	modal.size = Vector2(650, 500)
	modal.add_theme_stylebox_override("panel", box(Color("fff3dc"), 22, Color("dfc797")))
	add_child(modal)
	var mm := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		mm.add_theme_constant_override("margin_" + side, 28)
	modal.add_child(mm)
	modal_body = VBoxContainer.new()
	modal_body.add_theme_constant_override("separation", 14)
	mm.add_child(modal_body)
	modal.hide()
	focus_menu()

func focus_menu() -> void:
	for item in menu_buttons:
		if not item.disabled and item.is_visible_in_tree():
			item.grab_focus()
			return

func box(color: Color, radius: int, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.border_color = border
	style.set_border_width_all(1 if border.a > 0 else 0)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	return style

func label(parent: Node, text: String, font_size: int, color: Color) -> Label:
	var item := Label.new()
	item.text = text
	item.add_theme_font_size_override("font_size", font_size)
	item.add_theme_color_override("font_color", color)
	parent.add_child(item)
	return item

func button(parent: Node, text: String, action: Callable, primary: bool = false) -> Button:
	var item := Button.new()
	item.text = text
	item.custom_minimum_size.y = 56
	item.alignment = HORIZONTAL_ALIGNMENT_CENTER
	item.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	item.add_theme_font_size_override("font_size", 21)
	var clear := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		item.add_theme_stylebox_override(state, clear)
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.show_behind_parent = true
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://shaders/panel_button.gdshader")
	mat.set_shader_parameter("selected",primary)
	mat.set_shader_parameter("disabled",item.disabled)
	item.set_meta("button_material",mat)
	item.draw.connect(func():
		if mat.get_shader_parameter("disabled")!=item.disabled:
			mat.set_shader_parameter("disabled",item.disabled))
	mat.set_shader_parameter("panel_size",item.size)
	item.resized.connect(func():mat.set_shader_parameter("panel_size",item.size))
	bg.material = mat
	item.add_child(bg)
	item.mouse_entered.connect(func() -> void: preload("res://scripts/ui_motion.gd").hover(item,mat,0.0 if item.disabled else 1.0))
	item.mouse_exited.connect(func() -> void: preload("res://scripts/ui_motion.gd").hover(item,mat,0.0))
	item.add_theme_stylebox_override("focus", box(Color.TRANSPARENT, 12, Color("ffe1a0")))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		item.add_theme_color_override(state, Color("30271c"))
	item.add_theme_color_override("font_disabled_color",Color("51432f"))
	item.add_theme_color_override("font_shadow_color", Color(1, 0.91, 0.72, 0.5))
	item.add_theme_constant_override("shadow_offset_y", 1)
	item.pressed.connect(action)
	parent.add_child(item)
	return item

func open_modal(title: String) -> void:
	for child in modal_body.get_children():
		modal_body.remove_child(child)
		child.queue_free()
	modal.show()
	modal.modulate.a=0
	modal.create_tween().tween_property(modal,"modulate:a",1.0,.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	label(modal_body, title, 28, Color("30271c"))

func close_button() -> void:
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	modal_body.add_child(spacer)
	var close := button(modal_body, "←  Вернуться", close_modal)
	close.grab_focus()

func close_modal() -> void:
	modal.hide()
	focus_menu()

func paragraph(text: String) -> void:
	var item := label(modal_body, text, 18, Color("59432b"))
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.custom_minimum_size.x = 540

func show_new_game() -> void:
	open_modal("Начать новый обход?")
	paragraph("Опыт, навыки, записи и метки будут сброшены. Перед началом создаётся резервная копия; оригиналы фотографий остаются на диске.")
	button(modal_body,"Начать заново",func():
		var result:=preload("res://scripts/save_reset.gd").begin_new_game()
		if result.error==OK:show_start()
		else:paragraph("Сброс не выполнен: ошибка %d. Резервная копия: %s" % [result.error,result.backup]),true)
	close_button()

func show_start() -> void:
	get_tree().change_scene_to_file("res://scenes/loading.tscn")

func show_patrol() -> void:
	open_modal("Новые обходы — новые истории")
	paragraph("Патрули откроются после сюжетного обучения. Разные задания, погодные условия и груз будут менять каждый выход.")
	paragraph("Этот режим ещё не реализован. Здесь нет скрытого готового уровня.")
	close_button()

func show_about() -> void:
	open_modal("Оставь тропу лучше, чем нашёл")
	paragraph("Будущая игра о наблюдении за редкими растениями, помощи посетителям и работе природоохранной команды.")
	paragraph("Пейзаж меню — авторская стилизованная иллюстрация, не точная карта парка. Сюжетные события вымышлены.")
	paragraph("Управление меню: мышь, Tab, Enter. Esc — закрыть окно.")
	close_button()

func show_quit() -> void:
	open_modal("Завершить работу?")
	paragraph("Настройки уже сохранены. До следующего обхода!")
	button(modal_body, "Да, выйти", func() -> void: get_tree().quit(), true)
	close_button()

func show_settings() -> void:
	modal.hide()
	preload("res://scripts/game_settings.gd").make_panel(self, focus_menu)

func persist() -> void:
	var result := config.save(SAVE_PATH)
	apply_settings()
	if result != OK:
		status.text = "Не удалось сохранить настройки"

func apply_settings() -> void:
	AudioServer.set_bus_volume_linear(0, float(config.get_value("audio", "volume", 80)) / 100.0)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if config.get_value("display", "fullscreen", false) else DisplayServer.WINDOW_MODE_WINDOWED)
	if get_child_count() > 0:
		get_child(0).set_process(config.get_value("display", "animation", true))

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and modal.visible:
		close_modal()
		get_viewport().set_input_as_handled()
