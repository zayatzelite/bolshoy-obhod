extends "res://scripts/shore_connector_cart_test.gd"
var on_approach := true
var approach_progress := .35
func setup() -> void:
	super.setup()
	scene.player.position=preload("res://scripts/base_approach.gd").point(.35)+Vector3(0,.4,0)
	scene.cart.position=preload("res://scripts/base_approach.gd").point(.42)+Vector3(0,.4,0)
func _physics_process(delta: float) -> bool:
	if not is_instance_valid(scene):return false
	if not on_approach:return super._physics_process(delta)
	steps+=1
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	var target: Vector3=preload("res://scripts/base_approach.gd").point(minf(approach_progress+.025,.70))
	var offset: Vector3=target-scene.player.position
	offset.y=0
	if offset.length()<.4:approach_progress+=.009
	var direction: Vector3=offset.normalized()
	scene.player.rotation.y=atan2(-direction.x,-direction.z)
	scene.player.velocity=Vector3(direction.x*2,scene.player.velocity.y-delta*18,direction.z*2)
	scene.player.move_and_slide()
	scene._physics_process(delta)
	if not scene.player.dragging or steps>2000:
		push_error("Junction approach blocked");quit(1);return true
	if approach_progress>=.70:
		on_approach=false
		steps=0
		print("JUNCTION TURN START: continuous player/cart positions, four cargo")
	return false
