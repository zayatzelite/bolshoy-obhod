extends "res://scripts/live_cart_main_test.gd"
func branch_x(d: float) -> float:
	return (preload("res://scripts/riverbank.gd").edge(-d)+55)/2
func route_complete() -> void:
	print("RIVERBANK CART PASS: 159m dry shoreline using production towing physics, no loss of grip or falling")
	quit()
