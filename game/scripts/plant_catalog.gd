extends RefCounted

const EXPECTED_SPECIES := 22
var entries: Array[Dictionary] = []
var errors: PackedStringArray = []

func load_catalog(path: String = "res://data/plants.json") -> bool:
	entries.clear()
	errors.clear()
	if not FileAccess.file_exists(path):
		errors.append("База растений заказчика ещё не предоставлена.")
		return false
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return validate(parsed,true)

func validate(data: Variant, check_resources: bool = true) -> bool:
	entries.clear()
	errors.clear()
	if not data is Dictionary or not data.get("species") is Array:
		errors.append("Ожидается объект с массивом species.")
		return false
	var species: Array = data.species
	if species.size()!=EXPECTED_SPECIES:
		errors.append("Требуется 22 вида; получено %d." % species.size())
	var ids := {}
	for index in range(species.size()):
		var record = species[index]
		if not record is Dictionary:
			errors.append("Запись %d не является объектом." % index)
			continue
		for field in ["id","name_ru","name_latin","description","habitat","protection","source","photo","model"]:
			if not record.get(field) is String or str(record.get(field,"")).strip_edges().is_empty():
				errors.append("Запись %d: отсутствует %s." % [index,field])
		var id := str(record.get("id",""))
		if ids.has(id):errors.append("Повтор идентификатора: %s." % id)
		ids[id] = true
		if check_resources:
			for field in ["photo","model"]:
				var resource_path := str(record.get(field,""))
				if not resource_path.begins_with("res://") or not ResourceLoader.exists(resource_path):
					errors.append("Запись %d: ресурс %s недоступен." % [index,field])
					continue
				var resource = load(resource_path)
				if field=="photo" and not resource is Texture2D:
					errors.append("Запись %d: фотография должна быть Texture2D." % index)
				if field=="model":
					if not resource is PackedScene:
						errors.append("Запись %d: модель должна быть PackedScene." % index)
					else:
						var state: SceneState = resource.get_state()
						if state.get_node_count()==0 or not ClassDB.is_parent_class(state.get_node_type(0),"Node3D"):
							errors.append("Запись %d: корень модели должен быть Node3D." % index)
		entries.append(record.duplicate(true))
	if not errors.is_empty():
		entries.clear()
		return false
	return true

func find_species(id: String) -> Dictionary:
	for entry in entries:
		if entry.id==id:return entry.duplicate(true)
	return {}
