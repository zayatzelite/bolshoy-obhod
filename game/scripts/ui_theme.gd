extends RefCounted

static func panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(.19,.17,.13,.96)
	style.border_color = Color(.68,.58,.36,.85)
	style.set_border_width_all(1)
	style.set_corner_radius_all(16)
	style.set_content_margin_all(24)
	return style

static func skin_buttons(root: Node) -> void:
	if root is Button and not root.has_meta("stone_skin"):
		root.set_meta("stone_skin",true)
		var clear := StyleBoxEmpty.new()
		clear.set_content_margin_all(12)
		if root is CheckButton:
			clear.content_margin_left = 36
			clear.content_margin_right = 36
		for state in ["normal","hover","pressed","disabled"]:root.add_theme_stylebox_override(state,clear)
		var bg := ColorRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg.show_behind_parent = true
		var material := ShaderMaterial.new()
		material.shader = preload("res://shaders/menu_button.gdshader")
		material.set_shader_parameter("top_color",Color("d7bf91"))
		material.set_shader_parameter("bottom_color",Color("9f825e"))
		bg.material = material
		root.add_child(bg)
		root.mouse_entered.connect(func() -> void:material.set_shader_parameter("hover",0.0 if root.disabled else 1.0))
		root.mouse_exited.connect(func() -> void:material.set_shader_parameter("hover",0.0))
		for state in ["font_color","font_hover_color","font_pressed_color","font_hover_pressed_color","font_focus_color"]:root.add_theme_color_override(state,Color("30271c"))
		root.add_theme_color_override("font_disabled_color",Color("51432f"))
	for child in root.get_children():skin_buttons(child)

static func make_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font_size = 17
	for type in ["Label","Button","CheckButton"]:
		for state in ["font_color","font_hover_color","font_pressed_color","font_hover_pressed_color","font_focus_color"]:
			theme.set_color(state,type,Color("f3e8cb"))
		theme.set_color("font_disabled_color",type,Color("8b806c"))
	for state in ["normal","hover","pressed","disabled","focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("554936") if state=="normal" else Color("766044")
		if state=="disabled":style.bg_color = Color("393328")
		if state=="pressed":style.bg_color = Color("7c6942")
		style.border_color = Color("d8ba77") if state in ["hover","focus"] else Color("877357")
		style.set_border_width_all(2 if state=="focus" else 1)
		style.set_corner_radius_all(8)
		style.set_content_margin_all(10)
		theme.set_stylebox(state,"Button",style)
	var track := StyleBoxFlat.new()
	track.bg_color = Color("554936")
	track.set_corner_radius_all(4)
	track.content_margin_top = 4
	track.content_margin_bottom = 4
	theme.set_stylebox("slider","HSlider",track)
	var fill := track.duplicate() as StyleBoxFlat
	fill.bg_color = Color("d8ba77")
	theme.set_stylebox("grabber_area","HSlider",fill)
	theme.set_stylebox("grabber_area_highlight","HSlider",fill)
	for state in ["tab_selected","tab_unselected","tab_hovered","tab_disabled"]:
		var tab := StyleBoxFlat.new()
		tab.bg_color = Color("d7bf91") if state=="tab_selected" else Color("554936")
		tab.border_color = Color("bba278")
		tab.set_border_width_all(1)
		tab.corner_radius_top_left = 12
		tab.corner_radius_top_right = 3
		tab.content_margin_left = 28
		tab.content_margin_right = 28
		tab.content_margin_top = 16
		tab.content_margin_bottom = 16
		theme.set_stylebox(state,"TabContainer",tab)
		theme.set_stylebox(state,"TabBar",tab)
	for type in ["TabContainer","TabBar"]:
		theme.set_color("font_selected_color",type,Color("30271c"))
		theme.set_color("font_unselected_color",type,Color("f3e8cb"))
		theme.set_color("font_hovered_color",type,Color("fff0cc"))
	var tab_panel := StyleBoxFlat.new()
	tab_panel.bg_color = Color("393328")
	tab_panel.set_content_margin_all(28)
	theme.set_stylebox("panel","TabContainer",tab_panel)
	return theme
