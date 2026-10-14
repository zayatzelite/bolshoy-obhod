extends "res://scripts/base_approach_cart_test.gd"
var main_route := true
func setup() -> void:
	super.setup()
	scene.player.position = Vector3(2.5*sin(2*.035),.4,-2)
	scene.cart.position = Vector3(2.5*sin(4*.035),.4,-4)
func _physics_process(delta: float) -> bool:
	if not is_instance_valid(scene):return false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if not main_route:return super._physics_process(delta)
	steps+=1
	var d: float = -scene.player.position.z
	if d>=142.7:
		main_route=false
		steps=0
		return false
	var target := Vector3(2.5*sin((d+1)*.035),0,-d-1)
	var direction: Vector3 = target-scene.player.position
	direction.y=0
	direction=direction.normalized()
	scene.player.rotation.y=atan2(-direction.x,-direction.z)
	scene.player.velocity=Vector3(direction.x*2.8,scene.player.velocity.y-delta*18,direction.z*2.8)
	scene.player.move_and_slide()
	scene._physics_process(delta)
	if not scene.player.dragging or steps>4500:
		push_error("Full delivery main route blocked: player=%s cart=%s" % [scene.player.position,scene.cart.position]);quit(1);return true
	assert(scene.cargo==4)
	return false
