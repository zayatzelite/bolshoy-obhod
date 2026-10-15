extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var loading=load("res://scenes/loading.tscn").instantiate()
	root.add_child(loading)
	loading.set_process(false)
	loading.meter.value=67
	loading.badge.progress=67
	loading.status.text="Подготавливаем маршрут · 67%"
	await create_timer(.4).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("C:/Users/zayatz/Downloads/lenskiy stolbi/loading_art_preview.png")
	# Consume every threaded request before exiting the preview.
	for path in loading.ASSETS:ResourceLoader.load_threaded_get(path)
	ResourceLoader.load_threaded_get(loading.WORLD)
	print("LOADING ART PASS: illustrated background rendered and requests consumed")
	quit()
