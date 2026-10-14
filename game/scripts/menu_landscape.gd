extends Control

var time := 0.0

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func poly(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), color)

func tree(p: Vector2, height: float, tint: Color) -> void:
	draw_line(p, p-Vector2(0,height*0.75), Color("755337"), height*0.065)
	for j in range(5):
		var y := p.y-height+j*height*0.15
		var w := height*(0.17+j*0.035)
		poly([Vector2(p.x,y),Vector2(p.x-w*0.6,y+height*0.17),Vector2(p.x-w,y+height*0.29),Vector2(p.x+w,y+height*0.29),Vector2(p.x+w*0.6,y+height*0.17)],tint.lightened(j*0.035))
		poly([Vector2(p.x,y),Vector2(p.x-w,y+height*0.29),Vector2(p.x-3,y+height*0.25)],tint.lightened(0.16))

func _draw() -> void:
	draw_set_transform(Vector2.ZERO,0.0,size/Vector2(1280,720))
	for y in range(720):
		draw_line(Vector2(0,y),Vector2(1280,y),Color("369edc").lerp(Color("ffe9bb"),clampf(float(y)/530.0,0,1)),1.5)
	for radius in range(125,48,-4):
		draw_circle(Vector2(1040,115),radius,Color(1,0.88,0.52,0.012))
	draw_circle(Vector2(1040,115),43,Color("fff3bf"))
	for i in range(6):
		var c := Vector2(460+i*155,75+(i%3)*49)
		c.x += sin(time*0.08+i)*6
		for j in range(7):
			draw_circle(c+Vector2(j*15-42,sin(j*1.6+i)*8),13+sin(j)*5,Color(1,0.98,0.91,0.65))
	poly([Vector2(0,380),Vector2(200,300),Vector2(370,365),Vector2(650,245),Vector2(830,310),Vector2(1030,268),Vector2(1280,310),Vector2(1280,540),Vector2(0,540)],Color("83b9b3"))
	poly([Vector2(400,420),Vector2(650,335),Vector2(860,365),Vector2(1150,305),Vector2(1280,330),Vector2(1280,530),Vector2(400,530)],Color("639f93"))
	# Irregular, connected rock masses with lit ridges and darker gullies.
	for i in range(21):
		var x := 510.0+i*39.0
		var h := 145.0+sin(i*1.37)*42+sin(i*0.48)*55
		var b := 438.0+sin(i*0.6)*13
		var peak := Vector2(x+sin(i)*7,b-h)
		poly([Vector2(x-28,b),Vector2(x-20,b-h*0.64),peak+Vector2(-8,17),peak,peak+Vector2(12,7),Vector2(x+23,b-h*0.72),Vector2(x+29,b)],Color("c89b69"))
		poly([Vector2(x-23,b),Vector2(x-15,b-h*0.68),peak,peak+Vector2(3,14),Vector2(x+2,b)],Color("f2cf92"))
		poly([peak+Vector2(12,7),Vector2(x+23,b-h*0.72),Vector2(x+29,b),Vector2(x+11,b)],Color("a77655"))
		for j in range(5):
			var yy := b-h*0.13-j*h*0.14
			draw_line(Vector2(x-15,yy),Vector2(x+8,yy-3),Color(0.64,0.43,0.29,0.26),1.5)
		for j in range(2):
			draw_line(Vector2(x-6+j*12,b-h*0.72),Vector2(x-10+j*12,b-15),Color(0.63,0.44,0.29,0.4),2)
	for i in range(38):
		tree(Vector2(480+i*23,452+sin(i)*7),24+(i%5)*5,Color("408669"))
	# River gradient and reflected limestone highlights.
	for y in range(450,720):
		draw_line(Vector2(0,y),Vector2(1280,y),Color("57d4d5").lerp(Color("1688b1"),float(y-450)/270),1.5)
	for i in range(90):
		var x := 475+fmod(i*97.7+time*(3+i%4),820)
		var y := 455+(i*31)%230
		var reflection := Color(1,0.89,0.65,0.2) if i%3==0 else Color(0.8,1,1,0.35)
		draw_line(Vector2(x,y),Vector2(x+12+(i%7)*9,y),reflection,1.0+(i%2))
	poly([Vector2(0,574),Vector2(185,520),Vector2(367,558),Vector2(520,611),Vector2(650,720),Vector2(0,720)],Color("40934e"))
	poly([Vector2(790,720),Vector2(948,613),Vector2(1100,580),Vector2(1280,549),Vector2(1280,720)],Color("5ba74e"))
	poly([Vector2(852,720),Vector2(985,628),Vector2(1085,606),Vector2(1190,584),Vector2(1100,620),Vector2(1020,651),Vector2(966,720)],Color("d8ac6d"))
	poly([Vector2(875,720),Vector2(998,638),Vector2(1100,616),Vector2(1187,587),Vector2(1085,606),Vector2(985,628),Vector2(852,720)],Color("f5d49a"))
	for i in range(9):
		tree(Vector2(1125+(i*47)%155,597+(i*23)%115),65+(i%4)*24,Color("247d53"))
	tree(Vector2(552,665),147,Color("21674e"))
	tree(Vector2(40,705),190,Color("185b47"))
	# Foreground stones, grasses and small meadow flowers.
	for i in range(30):
		var p := Vector2(1050+(i*71)%220,674+(i*17)%45)
		if i%4==0:
			poly([p+Vector2(-13,2),p+Vector2(-8,-9),p+Vector2(6,-12),p+Vector2(15,0),p+Vector2(10,5)],Color("8ca395"))
		else:
			draw_line(p,p-Vector2(0,17),Color("a2cf63"),2)
			draw_line(p-Vector2(0,5),p+Vector2(7,-12),Color("a2cf63"),2)
			if i%3==0:
				for j in range(5):
					var a := j*TAU/5
					draw_circle(p-Vector2(0,20)+Vector2(cos(a),sin(a))*4,3,Color("ffd15a") if i%2==0 else Color("f49baf"))
				draw_circle(p-Vector2(0,20),2,Color("fff4ca"))
	# Small birds provide a sense of distance.
	for i in range(3):
		var p := Vector2(735+i*26,135+sin(time*0.7+i)*5)
		draw_polyline(PackedVector2Array([p+Vector2(-7,-2),p,p+Vector2(7,-2)]),Color("426f79"),1.5,true)
	draw_set_transform(Vector2.ZERO)
