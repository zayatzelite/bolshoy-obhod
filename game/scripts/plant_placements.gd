extends RefCounted
var errors: PackedStringArray = []

func validate(data: Variant, catalog: RefCounted) -> Array[Dictionary]:
	errors.clear()
	var result: Array[Dictionary] = []
	if not data is Dictionary or not data.get("placements") is Array:
		errors.append("Ожидается массив placements.")
		return result
	for entry in data.placements:
		if not entry is Dictionary or not entry.get("species_id") is String:
			errors.append("Некорректная запись точки.");continue
		if catalog.find_species(entry.species_id).is_empty():
			errors.append("Неизвестный вид: %s" % entry.species_id);continue
		var at = entry.get("position")
		if not at is Array or at.size()!=3:
			errors.append("Координаты должны содержать три числа.");continue
		var numeric := true
		for value in at:
			if not (value is float or value is int):numeric = false
		if not numeric:
			errors.append("Координаты должны быть числовыми.");continue
		var p := Vector3(float(at[0]),float(at[1]),float(at[2]))
		if not p.is_finite() or p.x < -47 or p.x > 51 or p.z > 22 or p.z < -208 or p.y < -1 or p.y > 8:
			errors.append("Точка вне игрового уровня.");continue
		if not entry.get("source") is String or str(entry.source).strip_edges().is_empty():
			errors.append("Нужен источник размещения точки.");continue
		result.append({"species_id":entry.species_id,"position":p,"source":entry.source})
	if not errors.is_empty():result.clear()
	return result

func spawn(parent: Node3D, catalog: RefCounted, path: String = "res://data/plant_placements.json") -> int:
	if not FileAccess.file_exists(path):return 0
	var placements := validate(JSON.parse_string(FileAccess.get_file_as_string(path)),catalog)
	var count := 0
	for entry in placements:
		var record: Dictionary = catalog.find_species(entry.species_id)
		var packed = load(record.model)
		if not packed is PackedScene:
			errors.append("Модель не является сценой: %s" % entry.species_id);continue
		var visual = packed.instantiate()
		if not visual is Node3D:
			visual.free();errors.append("Модель должна иметь 3D-корень.");continue
		var root := Node3D.new()
		root.name = "ProtectedPlant"
		root.position = entry.position
		root.add_child(visual)
		var body := StaticBody3D.new()
		body.collision_layer = 2
		body.collision_mask = 0
		body.set_meta("species_id",entry.species_id)
		body.set_meta("plant_visual",visual)
		var shape := CollisionShape3D.new()
		var sphere := SphereShape3D.new()
		sphere.radius = .3
		shape.shape = sphere
		shape.position.y = .3
		body.add_child(shape)
		root.add_child(body)
		parent.add_child(root)
		count+=1
	return count
