extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var flock := preload("res://scripts/sky_birds.gd").new()
	root.add_child(flock)
	assert(flock.birds.size()==7)
	for step in range(1200):
		flock.update_flight(1)
		for bird in flock.birds:
			assert(bird.position.y>16 and bird.position.y<23)
			assert(bird.position.x>=-12.01 and bird.position.x<=36.01)
			assert(bird.position.z>=-131.01 and bird.position.z<=-38.99)
			assert(absf(bird.get_child(0).rotation.z)<=.421)
	print("BIRDS PASS: seven animated silhouettes, twenty minutes of bounded continuous flight")
	quit()
