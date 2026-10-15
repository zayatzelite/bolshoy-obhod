extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var button:=CheckButton.new()
	button.text="Тени"
	root.add_child(button)
	preload("res://scripts/ui_theme.gd").skin_buttons(button)
	for state in ["normal","hover","pressed","hover_pressed","disabled"]:
		assert(button.get_theme_stylebox(state).content_margin_left==36,"Shifted text in "+state)
	button.button_pressed=true
	assert(button.get_meta("button_material").get_shader_parameter("selected"))
	button.button_pressed=false
	assert(not button.get_meta("button_material").get_shader_parameter("selected"))
	var material:ShaderMaterial=button.get_meta("button_material")
	assert(not material.get_shader_parameter("disabled"))
	button.disabled=true
	# Headless has no canvas draw; exercise the redraw hook used by BaseButton state updates.
	button.draw.emit()
	assert(material.get_shader_parameter("disabled"),"Disabled changed after skinning must reach the shader")
	button.disabled=false
	button.draw.emit()
	assert(not material.get_shader_parameter("disabled"),"Re-enabled buttons must restore active rendering")
	var ordinary:=Button.new()
	ordinary.toggle_mode=true
	ordinary.disabled=true
	root.add_child(ordinary)
	preload("res://scripts/ui_theme.gd").skin_buttons(ordinary)
	var ordinary_material:ShaderMaterial=ordinary.get_meta("button_material")
	assert(ordinary_material.get_shader_parameter("disabled"),"Initial disabled state must be synchronized")
	ordinary.button_pressed=true
	assert(ordinary_material.get_shader_parameter("selected"),"All toggle buttons must synchronize selection")
	ordinary.button_pressed=false
	assert(not ordinary_material.get_shader_parameter("selected"))
	button.free()
	ordinary.free()
	print("BUTTON STATES PASS: stable switch margins, toggle selection and initial/dynamic disabled material")
	quit()
