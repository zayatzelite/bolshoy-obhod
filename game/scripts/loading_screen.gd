extends Control
const WORLD := "res://scenes/world.tscn"
var meter: ProgressBar
var status: Label
var ready_frames := 0
const ASSETS := ["res://assets/patrol_location.glb", "res://assets/ranger_base.glb", "res://assets/detailed_waste_bin.glb", "res://assets/ranger_grip_continuous.glb", "res://assets/ranger_grip_bottle.glb", "res://assets/ranger_grip_can.glb", "res://assets/ranger_grip_cup.glb", "res://assets/litter_bottle.glb", "res://assets/litter_can.glb", "res://assets/litter_cup.glb", "res://assets/field_camera.glb", "res://assets/ranger_character_refined.glb"]
var warmed: Array[Resource] = []
# Compile GDScript on the main thread; the PackedScene and models still load in workers.
var world_script:Script
var badge:Control
func _ready() -> void:
	set_process(false)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background:=preload("res://scripts/loading_art.gd").new()
	add_child(background)
	var column:=VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	column.offset_left=-210
	column.offset_top=195
	column.offset_right=210
	column.offset_bottom=310
	column.add_theme_constant_override("separation",10)
	add_child(column)
	badge=preload("res://scripts/loading_badge.gd").new()
	badge.custom_minimum_size=Vector2(420,74)
	column.add_child(badge)
	var status_panel:=PanelContainer.new()
	status_panel.name="LoadingStatusPanel"
	status_panel.custom_minimum_size=Vector2(420,34)
	status_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var status_style:=StyleBoxFlat.new()
	status_style.bg_color=Color("e6d3a6")
	status_style.border_color=Color("a98a54")
	status_style.set_border_width_all(1)
	status_style.set_corner_radius_all(6)
	status_style.content_margin_left=12
	status_style.content_margin_right=12
	status_style.content_margin_top=6
	status_style.content_margin_bottom=6
	status_panel.add_theme_stylebox_override("panel",status_style)
	column.add_child(status_panel)
	status=Label.new()
	status.text="Подготавливаем маршрут…"
	status.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	status.mouse_filter=Control.MOUSE_FILTER_IGNORE
	status.add_theme_font_size_override("font_size",14)
	status.add_theme_color_override("font_color",Color("352f25"))
	status_panel.add_child(status)
	meter=ProgressBar.new()
	meter.custom_minimum_size=Vector2(560,14)
	meter.show_percentage=false
	var track:=StyleBoxFlat.new()
	track.bg_color=Color("574c36")
	track.set_corner_radius_all(6)
	meter.add_theme_stylebox_override("background",track)
	var fill:=StyleBoxFlat.new()
	fill.bg_color=Color("dfbb75")
	fill.set_corner_radius_all(6)
	meter.add_theme_stylebox_override("fill",fill)
	meter.hide()
	column.add_child(meter)
	var tip:=Label.new()
	tip.text="Изучайте растения, не срывая их. Мусор сдавайте на базе."
	tip.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	tip.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	tip.hide()
	column.add_child(tip)
	await get_tree().process_frame
	# A process tick alone does not guarantee that the loading cover was drawn.
	if DisplayServer.get_name()!="headless":await RenderingServer.frame_post_draw
	world_script=load("res://scripts/world.gd") as Script
	if world_script==null or not world_script.can_instantiate():
		fail_load("Не удалось подготовить код маршрута.")
		return
	for path in ASSETS:
		var asset_error:=ResourceLoader.load_threaded_request(path)
		if asset_error!=OK:
			fail_load("Не удалось начать загрузку ресурса (%d)." % asset_error)
			return
	var error:=ResourceLoader.load_threaded_request(WORLD)
	if error!=OK:fail_load("Не удалось начать загрузку мира (%d)." % error)
	else:set_process(true)
func fail_load(message:String) -> void:
	set_process(false)
	if is_inside_tree() and get_tree().root.has_meta("patrol_warmed_assets"):
		get_tree().root.remove_meta("patrol_warmed_assets")
	warmed.clear()
	world_script=null
	status.text=message+" Перезапустите игру."
func transition_to_world(packed:PackedScene) -> void:
	if packed==null or not packed.can_instantiate():
		fail_load("Не удалось подготовить сцену маршрута.")
		return
	set_process(false)
	# Keep preloaded assets alive across deletion of this loading scene.
	get_tree().root.set_meta("patrol_warmed_assets",warmed)
	var error:=get_tree().change_scene_to_packed(packed)
	if error!=OK:fail_load("Не удалось открыть маршрут (%d)." % error)
func _process(_delta: float) -> void:
	var progress:=[]
	var state:=ResourceLoader.load_threaded_get_status(WORLD,progress)
	var loaded_fraction:float=float(progress[0]) if not progress.is_empty() else 0.0
	if warmed.is_empty():
		for path in ASSETS:
			var asset_progress:=[]
			var asset_state:=ResourceLoader.load_threaded_get_status(path,asset_progress)
			if asset_state==ResourceLoader.THREAD_LOAD_LOADED:loaded_fraction+=1.0
			elif not asset_progress.is_empty():loaded_fraction+=float(asset_progress[0])
	else:loaded_fraction+=ASSETS.size()
	meter.value=maxf(meter.value,loaded_fraction/(ASSETS.size()+1)*90)
	badge.progress=meter.value
	if state==ResourceLoader.THREAD_LOAD_FAILED or state==ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		fail_load("Ошибка загрузки мира.")
	elif state==ResourceLoader.THREAD_LOAD_LOADED:
		if warmed.is_empty():
			for path in ASSETS:
				var asset_state:=ResourceLoader.load_threaded_get_status(path)
				if asset_state==ResourceLoader.THREAD_LOAD_IN_PROGRESS:return
				if asset_state!=ResourceLoader.THREAD_LOAD_LOADED:
					fail_load("Ошибка загрузки ресурсов маршрута.")
					return
			for path in ASSETS:
				var asset:=ResourceLoader.load_threaded_get(path)
				if asset==null:
					fail_load("Ресурс маршрута недоступен.")
					return
				warmed.append(asset)
		meter.value=90
		badge.progress=90
		status.text="Подготавливаем локацию…"
		ready_frames+=1
		if ready_frames>=3:
			transition_to_world(ResourceLoader.load_threaded_get(WORLD) as PackedScene)
