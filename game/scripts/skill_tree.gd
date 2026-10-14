extends Control
var world: Node3D
var nodes: Array[Button] = []
var points_label: Label
const KEYS := ["stamina","cart","boots"]
const TITLES := ["ВЫНОСЛИВОСТЬ","СНАРЯЖЕНИЕ","БЕЗОПАСНОСТЬ"]
func _ready() -> void:
	custom_minimum_size = Vector2(1200,550)
	points_label = Label.new()
	points_label.position = Vector2(30,8)
	add_child(points_label)
	for branch in range(3):
		var title := Label.new()
		title.text = TITLES[branch]
		title.position = Vector2(65+branch*390,55)
		title.add_theme_font_size_override("font_size",22)
		add_child(title)
		for rank in range(3):
			var button := Button.new()
			button.position = Vector2(50+branch*390,110+rank*115)
			button.custom_minimum_size = Vector2(310,75)
			button.set_meta("upgrade_key",KEYS[branch])
			button.set_meta("rank",rank+1)
			button.pressed.connect(func():purchase(KEYS[branch],rank+1))
			add_child(button)
			nodes.append(button)
	refresh()
	preload("res://scripts/ui_theme.gd").skin_buttons(self)
	refresh()
func purchase(key: String, rank: int) -> void:
	if not world.at_upgrade_station() or world.progression.ranks[key]!=rank-1:return
	world.progression.upgrade(key)
	refresh()
func refresh() -> void:
	points_label.text = "НАВЫКИ · %d очк." % world.progression.points()
	if not world.at_upgrade_station():points_label.text += " · Покупка у стенда базы"
	for button in nodes:
		var key: String = button.get_meta("upgrade_key")
		var rank: int = button.get_meta("rank")
		var owned: bool = world.progression.ranks[key]>=rank
		var effect := "Расход сил −%d%%" % (rank*15) if key=="stamina" else ("Тележка · %d мест" % (4+rank*2) if key=="cart" else "Урон от падения −%d%%" % (rank*20))
		var status := "ИЗУЧЕНО" if owned else "1 очко · Изучить"
		if not owned:
			if world.progression.ranks[key]!=rank-1:status = "Нужен уровень %d" % (rank-1)
			elif world.progression.points()<1:status = "Нет очков навыков"
			elif not world.at_upgrade_station():status = "Покупка на базе · 1 очко"
		button.text = "%s · %s\n%s" % ["✓" if owned else str(rank),status,effect]
		button.tooltip_text = effect+"\n"+status
		button.disabled = owned or not world.at_upgrade_station() or world.progression.points()<1 or world.progression.ranks[key]!=rank-1
		if owned:button.add_theme_color_override("font_disabled_color",Color("30271c"))
		else:button.remove_theme_color_override("font_disabled_color")
	queue_redraw()
func _draw() -> void:
	for branch in range(3):
		for rank in range(2):
			var x := 205+branch*390
			var learned: bool = world.progression.ranks[KEYS[branch]]>=rank+1
			draw_line(Vector2(x,185+rank*115),Vector2(x,225+rank*115),Color("ead29b") if learned else Color("766751"),4 if learned else 2,true)
