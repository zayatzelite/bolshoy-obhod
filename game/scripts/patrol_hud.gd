extends Control

var health_bar: ProgressBar
var stamina_bar: ProgressBar
var cargo_label: Label
var quest_label: Label
var xp_label: Label
var prompt_label: Label
var notice_label: Label
var navigation_label: Label
var xp_bar: ProgressBar
var hotbar_slots: Array[Label] = []
var hotbar_icons: Array[Control] = []
var compass: Control

func update_inventory(held: Node3D, items: Array) -> void:
	for index in range(4):
		var item: Node3D = held if index==0 else (items[index-1] if items.size()>=index else null)
		hotbar_slots[index].text = "РУКИ" if index==0 else str(index)
		hotbar_icons[index].title = str(item.get_meta("title","Предмет")) if is_instance_valid(item) else ""
		hotbar_icons[index].queue_redraw()

func style(color: Color, border: Color = Color("668979")) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(2)
	s.corner_radius_top_left = 14
	s.corner_radius_bottom_right = 14
	s.set_border_width_all(1)
	s.border_color = border
	s.set_content_margin_all(16)
	return s

func card(at: Vector2, dimensions: Vector2) -> VBoxContainer:
	var p := PanelContainer.new()
	p.position = at
	p.custom_minimum_size = dimensions
	var spacing := StyleBoxEmpty.new()
	spacing.set_content_margin_all(16)
	p.add_theme_stylebox_override("panel",spacing)
	add_child(p)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation",8)
	p.add_child(col)
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.show_behind_parent = true
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/hud_stone.gdshader")
	backdrop.material = material
	var backing_layer := Node2D.new()
	backing_layer.show_behind_parent = true
	p.add_child(backing_layer)
	backing_layer.add_child(backdrop)
	backdrop.size = p.size
	p.set_meta("stone_backdrop",backdrop)
	p.resized.connect(func():
		backdrop.position = Vector2.ZERO
		backdrop.size = p.size)
	return col

func caption(parent: Node, text: String, font_size: int = 17) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size",font_size)
	l.add_theme_color_override("font_color",Color("f3e8cb"))
	parent.add_child(l)
	return l

func meter(parent: Node, icon: String, color: Color) -> ProgressBar:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(252,32)
	bar.show_percentage = false
	var track := style(Color(0.08,0.16,0.14,.75))
	track.set_content_margin_all(0)
	bar.add_theme_stylebox_override("background",track)
	var fill := style(color,color)
	fill.set_content_margin_all(0)
	bar.add_theme_stylebox_override("fill",fill)
	row.add_child(bar)
	var symbol := TextureRect.new()
	symbol.texture = load("res://assets/ui/heart.svg" if icon=="♥" else "res://assets/ui/stamina.svg")
	symbol.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	symbol.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	symbol.position = Vector2(8,4)
	symbol.size = Vector2(24,24)
	symbol.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(symbol)
	var amount := Label.new()
	amount.name = "Amount"
	amount.position = Vector2(165,4)
	amount.size = Vector2(75,24)
	amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	amount.add_theme_font_size_override("font_size",15)
	amount.add_theme_color_override("font_color",Color("fff3d9"))
	amount.add_theme_color_override("font_shadow_color",Color(0,0,0,.7))
	amount.add_theme_constant_override("shadow_offset_x",1)
	amount.add_theme_constant_override("shadow_offset_y",1)
	amount.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(amount)
	return bar

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vitals := card(Vector2(24,540),Vector2(290,145))
	caption(vitals,"СОСТОЯНИЕ СМОТРИТЕЛЯ",13)
	health_bar = meter(vitals,"♥",Color("de826b"))
	stamina_bar = meter(vitals,"⚡",Color("e8c875"))
	var task := card(Vector2(24,24),Vector2(285,78))
	quest_label = caption(task,"ОБХОД · 0 / 8",16)
	var experience := card(Vector2(430,18),Vector2(420,76))
	xp_label = caption(experience,"УРОВЕНЬ 1 · 0 / 100 XP",15)
	xp_bar = ProgressBar.new()
	xp_bar.custom_minimum_size = Vector2(380,6)
	xp_bar.show_percentage = false
	var xp_track := style(Color("453d2d"))
	xp_track.set_content_margin_all(0)
	var xp_fill := style(Color("dfbb75"))
	xp_fill.set_content_margin_all(0)
	xp_bar.add_theme_stylebox_override("background",xp_track)
	xp_bar.add_theme_stylebox_override("fill",xp_fill)
	experience.add_child(xp_bar)
	var cargo := card(Vector2(1070,620),Vector2(185,65))
	cargo_label = caption(cargo,"▣ 0 / 4",18)
	var hint := card(Vector2(24,355),Vector2(250,70))
	prompt_label = caption(hint,"",15)
	prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_label.custom_minimum_size.x = 218
	for index in range(4):
		var slot := card(Vector2(400+index*120,590),Vector2(110,95))
		var label := caption(slot,"—",13)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size.x = 78
		hotbar_slots.append(label)
		var icon := preload("res://scripts/item_icon.gd").new()
		icon.custom_minimum_size = Vector2(60,48)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(icon)
		hotbar_icons.append(icon)
	var notice := card(Vector2(950,200),Vector2(305,70))
	notice_label = caption(notice,"",16)
	notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice_label.custom_minimum_size.x = 273
	hint.get_parent().hide()
	notice.get_parent().hide()
	var cross := Label.new()
	cross.text = "·"
	cross.add_theme_font_size_override("font_size",30)
	cross.position = Vector2(635,340)
	add_child(cross)
	compass = preload("res://scripts/patrol_compass.gd").new()
	compass.position = Vector2(430,100)
	compass.size = Vector2(420,60)
	add_child(compass)
	navigation_label = Label.new()
	navigation_label.hide()
	add_child(navigation_label)

func _process(_delta: float) -> void:
	if is_instance_valid(prompt_label):
		prompt_label.get_parent().get_parent().visible = not prompt_label.text.is_empty()
		notice_label.get_parent().get_parent().visible = not notice_label.text.is_empty()

func update_values(health: float, stamina: float, cargo: int, capacity: int, delivered: int, xp: int) -> void:
	health_bar.value = health
	stamina_bar.value = stamina
	health_bar.get_node("Amount").text = "%d / 100" % clampi(roundi(health),0,100)
	stamina_bar.get_node("Amount").text = "%d / 100" % clampi(roundi(stamina),0,100)
	cargo_label.text = "▣ %d / %d" % [cargo,capacity]
	quest_label.text = "ОБХОД · %d / 8" % delivered
	var current := xp%100
	xp_label.text = "УРОВЕНЬ %d · %d / 100 XP · ещё %d" % [1+xp/100,current,100-current]
	xp_bar.value = current
