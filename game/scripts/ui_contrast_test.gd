extends SceneTree
func luminance(color:Color) -> float:
	var linear:=color.srgb_to_linear()
	return .2126*linear.r+.7152*linear.g+.0722*linear.b
func ratio(a:Color,b:Color) -> float:
	return (maxf(luminance(a),luminance(b))+.05)/(minf(luminance(a),luminance(b))+.05)
func shader_palette(shader:Shader) -> Dictionary:
	# Dummy headless renderer returns Nil for shader defaults; read declarations directly.
	var pattern:=RegEx.new()
	pattern.compile("uniform vec3 (\\w+)\\s*=\\s*vec3\\(([^,]+),([^,]+),([^\\)]+)\\)")
	var colors:Dictionary={}
	for result in pattern.search_all(shader.code):
		colors[result.get_string(1)]=Vector3(float(result.get_string(2)),float(result.get_string(3)),float(result.get_string(4)))
	return colors
func _initialize() -> void:
	var theme=preload("res://scripts/ui_theme.gd").make_theme()
	var ink:Color=theme.get_color("font_color","Label")
	for paper in [Color("d7bf91"),Color("d9bd88"),Color("e5cca0"),Color(.72,.54,.30)]:
		assert(ratio(ink,paper)>=4.5,"Panel text contrast below 4.5")
	for state in ["normal","hover","pressed","disabled"]:
		var background:StyleBoxFlat=theme.get_stylebox(state,"Button")
		var text:Color=theme.get_color("font_disabled_color" if state=="disabled" else "font_color","Button")
		assert(ratio(text,background.bg_color)>=4.5,"Button contrast: "+state)
	assert(ratio(theme.get_color("font_color","TooltipLabel"),theme.get_stylebox("panel","TooltipPanel").bg_color)>=4.5)
	# Audit the actual shader defaults, not just the StyleBoxFlat replaced by skin_buttons.
	# Text lies inside the rim/ornaments; sample the complete interior gradient.
	var button:=Button.new()
	preload("res://scripts/ui_theme.gd").skin_buttons(button)
	var material:ShaderMaterial=button.get_meta("button_material")
	var palette:=shader_palette(material.shader)
	for disabled in [false,true]:
		var top:Vector3=palette["disabled_top" if disabled else "active_top"]
		var bottom:Vector3=palette["disabled_bottom" if disabled else "active_bottom"]
		var text:Color=button.get_theme_color("font_disabled_color" if disabled else "font_color")
		for step in range(101):
			var rgb:=top.lerp(bottom,step/100.0)
			var background:=Color(rgb.x,rgb.y,rgb.z)
			# Active alpha .98 can composite over a completely dark scene.
			if not disabled:background=Color(rgb.x*.98,rgb.y*.98,rgb.z*.98)
			assert(ratio(text,background)>=4.5,"Shader interior contrast: disabled=%s y=%d" % [disabled,step])
	button.free()
	print("UI CONTRAST PASS: panels, button shader gradients (including disabled) and tooltip >=4.5:1")
	quit()
