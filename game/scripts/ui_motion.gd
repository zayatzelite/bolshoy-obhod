extends RefCounted
static func reveal(panel:Control) -> void:
	if panel.has_meta("motion_revealed"):return
	panel.set_meta("motion_revealed",true)
	panel.modulate.a=0.0
	var tween:=panel.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel,"modulate:a",1.0,.24)
static func switch_content(content:Control) -> void:
	var old:Variant=content.get_meta("content_tween") if content.has_meta("content_tween") else null
	if old is Tween and old.is_valid():old.kill()
	content.modulate.a=.18
	var tween:=content.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	content.set_meta("content_tween",tween)
	tween.tween_property(content,"modulate:a",1.0,.20)

static func hover(button:Control,material:ShaderMaterial,value:float) -> void:
	var old:Variant=button.get_meta("hover_tween") if button.has_meta("hover_tween") else null
	if old is Tween and old.is_valid():old.kill()
	var tween:=button.create_tween()
	button.set_meta("hover_tween",tween)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var current:Variant=material.get_shader_parameter("hover")
	tween.tween_method(func(amount:float):material.set_shader_parameter("hover",amount),float(current) if current!=null else 0.0,value,.16)
