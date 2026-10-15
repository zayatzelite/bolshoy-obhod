extends CharacterBody3D

const Settings = preload("res://scripts/game_settings.gd")
const CHARACTER_BODY_PATH := "res://assets/ranger_character_refined.glb"
var camera: Camera3D
var stamina := 100.0
var health := 100.0
var settings: Dictionary
var dragging := false
var walking_time := 0.0
var last_fall := 0.0
var carrying_hand: Node3D
var grip_variants:Dictionary={}
var active_grip:=""
var carry_rig: Node3D
var carry_raise := 0.0
var last_held: Node3D
var photo_camera: Node3D
var camera_equipped := false
var camera_blend := 0.0
var camera_aim := 0.0
var shutter_recoil:=0.0
var camera_support_hand: Node3D
var character_body: Node3D
var body_animator: AnimationPlayer
var body_shadow_sources: Array[MeshInstance3D] = []
var body_shadow_proxies: Array[MeshInstance3D] = []

func sync_body_shadow_proxies() -> void:
	for index in range(body_shadow_sources.size()):
		var source := body_shadow_sources[index]
		var proxy := body_shadow_proxies[index]
		proxy.transform = source.transform
		proxy.visible = source.visible

func configure_body_visibility() -> void:
	# Camera layers also cull shadow casters. Keep originals for external cameras,
	# but provide a shadows-only copy on the FPS-visible layer for each upper part.
	for mesh: MeshInstance3D in character_body.find_children("*", "MeshInstance3D", true, false):
		mesh.visible = true
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		var part_name := str(mesh.name)
		if part_name.begins_with("Boot") or part_name.begins_with("Thigh"):
			mesh.layers = 1
			continue
		mesh.layers = 2
		var proxy := MeshInstance3D.new()
		proxy.name = part_name + "ShadowProxy"
		proxy.mesh = mesh.mesh
		proxy.skin = mesh.skin
		proxy.skeleton = mesh.skeleton
		proxy.material_override = mesh.material_override
		proxy.layers = 1
		proxy.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		mesh.get_parent().add_child(proxy)
		body_shadow_sources.append(mesh)
		body_shadow_proxies.append(proxy)
	camera.cull_mask = camera.cull_mask & ~2
	sync_body_shadow_proxies()

func update_body_animation() -> void:
	sync_body_shadow_proxies()
	if not is_instance_valid(body_animator):return
	if Input.mouse_mode!=Input.MOUSE_MODE_CAPTURED:
		body_animator.pause()
		return
	var speed:=Vector2(velocity.x,velocity.z).length()
	var animation: StringName="Idle" if speed<.2 else ("Run" if speed>5.0 else "Walk")
	if body_animator.current_animation!=animation:body_animator.play(animation,.18)
	elif not body_animator.is_playing():body_animator.play()
	body_animator.speed_scale=1.0 if speed<.2 else clampf(speed/(7.0 if speed>5 else 4.0),.4,1.5)
func toggle_camera() -> void:
	if is_instance_valid(get_parent().held_item) or dragging:
		get_parent().notify("Освободите руки для фотоаппарата.")
		return
	camera_equipped=not camera_equipped
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
	carry_rig = Node3D.new()
	carry_rig.name = "FirstPersonCarryRig"
	camera.add_child(carry_rig)
	carrying_hand = (load("res://assets/ranger_grip_continuous.glb") as PackedScene).instantiate()
	carry_rig.add_child(carrying_hand)
	carrying_hand.position = Vector3(.28,-.43,-.60)
	carrying_hand.scale = Vector3(1,1.65,1)
	carrying_hand.rotation.z = .12
	for mesh in carrying_hand.find_children("*","MeshInstance3D",true,false):
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	carrying_hand.hide()
	for key in ["bottle","can","cup"]:
		var variant:Node3D=(load("res://assets/ranger_grip_"+key+".glb") as PackedScene).instantiate()
		variant.position=Vector3(.34,-.43,-.60)
		variant.scale=carrying_hand.scale
		variant.rotation=Vector3(0,0,.85)
		for mesh in variant.find_children("*","MeshInstance3D",true,false):mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		variant.hide()
		carry_rig.add_child(variant)
		grip_variants[key]=variant

func select_item_grip(held:Node3D) -> void:
	var key:=""
	if is_instance_valid(held):
		var title:=str(held.get_meta("title",""))
		key="can" if title.contains("банка") else ("cup" if title.contains("стакан") else "bottle")
	for variant in grip_variants.values():variant.hide()
	if not key.is_empty() and not camera_equipped:
		var variant:Node3D=grip_variants[key]
		variant.visible=carrying_hand.visible
		carrying_hand.hide()
	active_grip=key

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

func _process(delta: float) -> void:
	update_body_animation()
	if is_instance_valid(carrying_hand):
		var held: Node3D = get_parent().held_item
		if is_instance_valid(held) or dragging:camera_equipped=false
		camera_blend=move_toward(camera_blend,1.0 if camera_equipped else 0.0,delta*4)
		photo_camera.visible=camera_blend>0.01 and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED
		var aiming:=camera_equipped and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		camera_aim=move_toward(camera_aim,1.0 if aiming else 0.0,delta*5)
		photo_camera.position=Vector3(.25,-.65,-.60).lerp(Vector3(.20,-.28,-.55).lerp(Vector3(0,-.035,-.20),camera_aim),camera_blend)
		photo_camera.visible=photo_camera.visible and camera_aim<.68
		camera.fov=lerpf(float(settings.fov),float(settings.fov)*.72,camera_aim)
		carrying_hand.position=Vector3(.28,-.43,-.60)
		if camera_equipped:
			carrying_hand.position=photo_camera.position+Vector3(.085,-.095,.035)
			camera_support_hand.position=photo_camera.position+Vector3(-.105,-.105,-.10)
			camera_support_hand.rotation=Vector3(.12,-.15,.20)
		camera_support_hand.visible=camera_equipped and camera_aim<.68 and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED
		carrying_hand.visible = (is_instance_valid(held) or (camera_equipped and camera_aim<.68)) and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED
		select_item_grip(held)
		if held!=last_held:
			carry_raise=1.0
			last_held=held
		carry_raise=move_toward(carry_raise,0.0,delta*3.5)
		var moving:=minf(Vector2(velocity.x,velocity.z).length()/4.0,1.4)
		carry_rig.position=Vector3(sin(walking_time*1.7)*.012*moving,-carry_raise*.22+absf(sin(walking_time*2))*.009*moving,0)
		shutter_recoil=move_toward(shutter_recoil,0.0,delta*6)
		carry_rig.rotation=Vector3(sin(walking_time*2)*.012*moving-shutter_recoil*.045,0,sin(walking_time)*.018*moving)

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
	photo_camera=(load("res://assets/field_camera.glb") as PackedScene).instantiate()
	carry_rig.add_child(photo_camera)
	photo_camera.scale=Vector3.ONE*1.7
	# Blender front is -Y, exported to -Z; point the lens into the world.
	photo_camera.rotation.y=PI
	photo_camera.hide()
	camera_support_hand=carrying_hand.duplicate() as Node3D
	camera_support_hand.name="CameraSupportHand"
	carry_rig.add_child(camera_support_hand)
	camera_support_hand.scale=Vector3(-1,1.35,1)
	camera_support_hand.hide()
	character_body=(load(CHARACTER_BODY_PATH) as PackedScene).instantiate()
	character_body.name="RangerAnimatedBody"
	add_child(character_body)
	# Keep the full-body rig available without rendering head/body through the FPS camera.
	character_body.position=Vector3(0,0,.12)
	configure_body_visibility()
	var animators:=character_body.find_children("*","AnimationPlayer",true,false)
	if not animators.is_empty():
		body_animator=animators[0]
		for key in ["Idle","Walk","Run"]:
			body_animator.get_animation(key).loop_mode=Animation.LOOP_LINEAR
		body_animator.play("Idle")
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
