extends CharacterBody3D

const Settings = preload("res://scripts/game_settings.gd")
var camera: Camera3D
var stamina := 100.0
var health := 100.0
var settings: Dictionary
var dragging := false
var walking_time := 0.0
var last_fall := 0.0
var carrying_hand: Node3D
var jump_was_pressed := false
var sprint_exhausted := false

func can_sprint(requested: bool, moving: bool) -> bool:
	if stamina<=2:sprint_exhausted = true
	elif stamina>=20:sprint_exhausted = false
	return requested and moving and not dragging and not sprint_exhausted

func consume_jump_press(pressed: bool) -> bool:
	var fresh := pressed and not jump_was_pressed
	jump_was_pressed = pressed
	return fresh

func make_carrying_hand() -> void:
	carrying_hand = (load("res://assets/ranger_hand.glb") as PackedScene).instantiate()
	camera.add_child(carrying_hand)
	carrying_hand.position = Vector3(.22,-.26,-.72)
	carrying_hand.rotation.z = .35
	for mesh in carrying_hand.find_children("*","MeshInstance3D",true,false):
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	carrying_hand.hide()

func make_legacy_carrying_hand() -> void:
	carrying_hand = Node3D.new()
	camera.add_child(carrying_hand)
	carrying_hand.position = Vector3(-.13,.05,-.17)
	var glove := StandardMaterial3D.new()
	glove.albedo_color = Color("ac9b73")
	glove.roughness = .95
	var sleeve := StandardMaterial3D.new()
	sleeve.albedo_color = Color("395f4b")
	sleeve.roughness = .95
	for entry in [[Vector3(.35,-.44,-.55),Vector3(.135,.30,.19),sleeve],[Vector3(.35,-.335,-.60),Vector3(.13,.16,.17),glove]]:
		var mesh := MeshInstance3D.new()
		var rounded := CapsuleMesh.new()
		rounded.radius = .5
		rounded.height = 2
		mesh.mesh = rounded
		mesh.scale = Vector3(entry[1].x,entry[1].y*.5,entry[1].z)
		mesh.position = entry[0]
		mesh.material_override = entry[2]
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		carrying_hand.add_child(mesh)
	for index in range(4):
		var finger := MeshInstance3D.new()
		var capsule := CapsuleMesh.new()
		capsule.radius = .014
		capsule.height = .09
		finger.mesh = capsule
		finger.position = Vector3(.302+index*.031,-.295,-.65)
		finger.rotation.x = .8
		finger.material_override = glove
		finger.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		carrying_hand.add_child(finger)
	var thumb := MeshInstance3D.new()
	var thumb_mesh := CapsuleMesh.new()
	thumb_mesh.radius = .023
	thumb_mesh.height = .11
	thumb.mesh = thumb_mesh
	thumb.position = Vector3(.30,-.30,-.59)
	thumb.rotation.z = -.55
	thumb.rotation.x = .35
	thumb.material_override = glove
	thumb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	carrying_hand.add_child(thumb)
	carrying_hand.hide()

func _process(_delta: float) -> void:
	if is_instance_valid(carrying_hand):
		carrying_hand.visible = is_instance_valid(get_parent().held_item) and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	settings = Settings.read_values()
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.8
	shape.shape = capsule
	shape.position.y = 0.9
	add_child(shape)
	camera = Camera3D.new()
	camera.position.y = 1.65
	camera.fov = settings.fov
	add_child(camera)
	make_carrying_hand()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * float(settings.sensitivity))
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * float(settings.sensitivity) * (-1.0 if settings.invert_y else 1.0), -1.4, 1.4)

func _physics_process(delta: float) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		jump_was_pressed = Input.is_physical_key_pressed(KEY_SPACE)
		return
	var jump_pressed := consume_jump_press(Input.is_physical_key_pressed(KEY_SPACE))
	var input := Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)), float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
	var direction := (transform.basis * Vector3(input.x, 0, input.y)).normalized()
	var sprint := can_sprint(Input.is_physical_key_pressed(KEY_SHIFT),input.length()>0)
	var speed := 7.0 if sprint else 4.0
	if dragging:
		speed = 2.8
	var stamina_cost: float = 20.0 * (1.0-0.15*get_parent().progression.ranks.stamina)
	stamina = clampf(stamina + (-stamina_cost if sprint else 13.0) * delta, 0, 100)
	velocity.x = move_toward(velocity.x, direction.x*speed, 22*delta)
	velocity.z = move_toward(velocity.z, direction.z*speed, 22*delta)
	if not is_on_floor():
		velocity.y -= 18*delta
		last_fall = minf(last_fall, velocity.y)
	else:
		if last_fall < -13:
			health = maxf(0, health-(-last_fall-13)*4*(1.0-0.2*get_parent().progression.ranks.boots))
		last_fall = 0
		if jump_pressed and not dragging:
			velocity.y = 6.2
	move_and_slide()
	walking_time += delta * Vector2(velocity.x,velocity.z).length()
	camera.position.y = 1.65 + (sin(walking_time*2)*0.025 if settings.bob and is_on_floor() else 0.0)
	if position.y < -5 or health <= 0 or position.x < -50 or position.x > 54 or position.z > 25 or position.z < -211:
		position = Vector3(0,0.2,8)
		velocity = Vector3.ZERO
		health = 100
		dragging = false
		last_fall = 0
		stamina = 100
		get_parent().recover_cart()
		get_parent().notify("Эвакуация на базу. Будьте осторожнее у обрывов и воды.")
