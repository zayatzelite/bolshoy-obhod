extends SceneTree
var ticks:=0
var done:=false
var loading_checked:=false
var previous_progress:=0.0
var stage_frames:=0
var longest_frame:=0.0
func _initialize() -> void:call_deferred("begin")
func begin() -> void:
	check_error_guards()
	assert(change_scene_to_file("res://scenes/loading.tscn")==OK)
func check_error_guards() -> void:
	# Attach the fixture before assigning its script: do not run _ready/worker requests.
	var fixture:=Control.new()
	root.add_child(fixture)
	fixture.set_script(load("res://scripts/loading_screen.gd"))
	fixture.status=Label.new()
	fixture.add_child(fixture.status)
	fixture.warmed.append(Resource.new())
	root.set_meta("patrol_warmed_assets",fixture.warmed)
	fixture.set_process(true)
	fixture.transition_to_world(null)
	assert(not root.has_meta("patrol_warmed_assets"))
	assert(not fixture.is_processing() and fixture.warmed.is_empty())
	assert(fixture.world_script==null)
	assert(fixture.status.text.contains("Перезапустите игру."))
	fixture.transition_to_world(PackedScene.new())
	assert(fixture.status.text.contains("сцену маршрута"))
	fixture.free()
	print("LOADING ERROR GUARDS PASS: null/empty scene rejected with readable error")
func _process(_delta: float) -> bool:
	if done:return false
	longest_frame=maxf(longest_frame,_delta)
	ticks+=1
	if current_scene and current_scene.name=="LoadingScreen" and ticks>3:
		var panel:Control=current_scene.get_child(1)
		var rect:=panel.get_global_rect()
		assert(rect.position.x>=0 and rect.position.y>=0)
		assert(rect.end.x<=root.get_visible_rect().size.x and rect.end.y<=root.get_visible_rect().size.y)
		var status_label:Label=current_scene.status
		var status_panel:=status_label.get_parent() as PanelContainer
		assert(status_panel!=null and status_panel.name=="LoadingStatusPanel")
		var status_style:=status_panel.get_theme_stylebox("panel") as StyleBoxFlat
		assert(status_style!=null and is_equal_approx(status_style.bg_color.a,1.0))
		assert(status_style.bg_color==Color("e6d3a6"))
		assert(status_label.get_theme_color("font_color")==Color("352f25"))
		assert(status_label.get_theme_font_size("font_size")>=14)
		assert(status_label.autowrap_mode==TextServer.AUTOWRAP_WORD_SMART)
		var status_rect:=status_panel.get_global_rect()
		assert(rect.encloses(status_rect))
		assert(status_rect.size.y>=34)
		loading_checked=true
		assert(current_scene.badge.progress>=previous_progress)
		previous_progress=current_scene.badge.progress
	if current_scene and current_scene.name=="FirstPatrol" and not current_scene.build_complete:
		stage_frames+=1
		assert(not current_scene.is_physics_processing())
		if is_instance_valid(current_scene.build_badge):
			assert(current_scene.build_badge.progress>=previous_progress)
			previous_progress=current_scene.build_badge.progress
	if current_scene and current_scene.name=="FirstPatrol" and current_scene.build_complete:
		assert(loading_checked and stage_frames>=6)
		assert(not root.has_meta("patrol_warmed_assets"))
		assert(current_scene.is_physics_processing() and current_scene.is_processing())
		print("LOADING TRANSITION PASS: loading scene reached playable world in %d frames" % ticks)
		print("LOADING TIMING: longest frame %.3f seconds; %d staged frames" % [longest_frame,stage_frames])
		done=true
		call_deferred("finish")
		return false
	if ticks>1200:push_error("Loading transition timeout");quit(1);return true
	return false
func finish() -> void:
	await process_frame
	if current_scene:
		current_scene.queue_free()
	await process_frame
	await process_frame
	quit()
