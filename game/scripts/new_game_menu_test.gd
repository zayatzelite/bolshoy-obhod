extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	# Read-only smoke: do not invoke actual reset on the user's saves.
	var reset=load("res://scripts/save_reset.gd")
	assert(reset.FILES.size()==3)
	var menu=load("res://scripts/main_menu.gd").new()
	root.add_child(menu)
	var continue_button:Button=menu.menu_buttons[0]
	var new_game:Button=menu.menu_buttons[1]
	var continue_material:ShaderMaterial=continue_button.get_meta("button_material")
	assert(continue_material.get_shader_parameter("disabled")==continue_button.disabled)
	assert(root.gui_get_focus_owner()==(new_game if continue_button.disabled else continue_button),"Initial focus must skip disabled Continue")
	# Simulate both save states without modifying or deleting the user's save files.
	continue_button.disabled=true
	continue_button.draw.emit()
	assert(continue_material.get_shader_parameter("disabled"))
	menu.focus_menu()
	assert(root.gui_get_focus_owner()==new_game)
	menu.show_new_game()
	assert(menu.modal.visible)
	var confirm:=false
	for button in menu.modal_body.find_children("*","Button",true,false):
		if button.text=="Начать заново":confirm=true
	assert(confirm)
	assert(menu.modal_body.get_child(0).get_theme_color("font_color")==Color("30271c"))
	assert(menu.modal_body.get_child(1).get_theme_color("font_color")==Color("59432b"))
	menu.close_modal()
	assert(root.gui_get_focus_owner()==new_game,"Modal return focus must skip disabled Continue")
	menu.show_settings()
	var return_button:Button=menu.find_child("SettingsReturn",true,false)
	assert(is_instance_valid(return_button))
	return_button.pressed.emit()
	assert(root.gui_get_focus_owner()==new_game,"Settings return must skip disabled Continue")
	continue_button.disabled=false
	continue_button.draw.emit()
	assert(not continue_material.get_shader_parameter("disabled"))
	assert(continue_material.get_shader_parameter("selected"),"Re-enabled primary button retains gold selection")
	menu.focus_menu()
	assert(root.gui_get_focus_owner()==continue_button)
	menu.queue_free()
	await process_frame
	print("NEW GAME MENU PASS: reset confirmation, enabled initial/return focus, shader disabled sync and warm ink; user saves unchanged")
	quit()
