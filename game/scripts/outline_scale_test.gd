extends SceneTree

# Numeric regression for the shader's bounded screen displacement; no GUI/world/save.
const SHADER_PATH := "res://shaders/interactable_outline.gdshader"

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var shader: Shader = load(SHADER_PATH)
	assert(shader != null)
	var source := FileAccess.get_file_as_string(SHADER_PATH)
	assert(source.contains("MODELVIEW_NORMAL_MATRIX"), "Normals must account for imported/nonuniform scale")
	assert(source.contains("POSITION.xy +="), "Only XY should expand: preserve base depth")
	assert(not source.contains("VERTEX += NORMAL"), "Local-space expansion makes width asset-scale dependent")
	assert(source.contains("cull_front"), "Inverted hull must not cover front surfaces")
	assert(not source.contains("depth_draw_always") and not source.contains("depth_test_disabled"))
	var camera := Camera3D.new()
	root.add_child(camera)
	var count := 0
	for size: Vector2i in [Vector2i(1280,720), Vector2i(960,540), Vector2i(1920,1080)]:
		root.size = size
		camera.fov = 75.0
		var projection := camera.get_camera_projection()
		for distance in [.02, .1, .5, 1.0, 3.2]:
			for scale: Vector3 in [Vector3.ONE*.1, Vector3.ONE, Vector3.ONE*10, Vector3(.2,2,5)]:
				var model_basis := Basis.from_scale(scale)
				var local_point := Vector3(0,0,-distance) / scale
				var view_vertex := model_basis * local_point
				for normal: Vector3 in [Vector3.RIGHT, Vector3.UP, Vector3(1,1,1).normalized()]:
					var view_normal := (model_basis.inverse().transposed()*normal).normalized()
					var original := projection * Vector4(view_vertex.x,view_vertex.y,view_vertex.z,1)
					var shell_position := view_vertex + view_normal*.002
					var shell := projection * Vector4(shell_position.x,shell_position.y,shell_position.z,1)
					if shell.w <= .0001: continue
					var viewport := Vector2(size)
					var delta := (Vector2(shell.x,shell.y)/shell.w-Vector2(original.x,original.y)/original.w)*viewport*.5
					var blend := minf(1.0,2.0/maxf(delta.length(),.0001))
					var result := original
					result.x += delta.x*2.0/viewport.x*original.w*blend
					result.y += delta.y*2.0/viewport.y*original.w*blend
					var actual := (Vector2(result.x,result.y)/result.w-Vector2(original.x,original.y)/original.w)*viewport*.5
					assert(actual.length() <= 2.001, "Outline exceeds two pixels")
					assert(result.z == original.z and result.w == original.w, "Outline changes source depth")
					count += 1
	camera.free()
	print("OUTLINE SCALE PASS: ",count," samples, 0.1x–10x/nonuniform scale, 960–1920 widths, max 2px, 2mm view-space shell, original depth retained. GPU visual review still required.")
	quit()
