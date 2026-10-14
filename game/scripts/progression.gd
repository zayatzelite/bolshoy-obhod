extends RefCounted

const PATH := "user://progress.cfg"
const LIMIT := 3
var xp := 0
var spent := 0
var ranks := {"stamina": 0, "cart": 0, "boots": 0}

func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	apply_loaded_values(cfg)

func safe_integer(value: Variant, maximum: int) -> int:
	if value is int:return clampi(value,0,maximum)
	if value is float and is_finite(value):return int(clampf(value,0,maximum))
	return 0

func apply_loaded_values(cfg: ConfigFile) -> void:
	xp = safe_integer(cfg.get_value("progress","xp",0),100000000)
	spent = safe_integer(cfg.get_value("progress","spent",0),1000000)
	for key in ranks:
		ranks[key] = safe_integer(cfg.get_value("upgrades",key,0),LIMIT)
	# Never grant extra points when a damaged save understates purchased ranks.
	var purchased := 0
	for rank in ranks.values():purchased += int(rank)
	spent = maxi(spent,purchased)

func save_progress() -> Error:
	var cfg := ConfigFile.new()
	cfg.set_value("progress","xp",xp)
	cfg.set_value("progress","spent",spent)
	for key in ranks:
		cfg.set_value("upgrades",key,ranks[key])
	return cfg.save(PATH)

func points() -> int:
	return maxi(0,floori(float(xp)/100.0)-spent)

func award(amount: int) -> Error:
	var before := xp
	xp += maxi(0,amount)
	var result := save_progress()
	if result!=OK:xp = before
	return result

func upgrade(key: String) -> bool:
	if not ranks.has(key) or ranks[key]>=LIMIT or points()<1:
		return false
	ranks[key]+=1
	spent+=1
	if save_progress()!=OK:
		ranks[key]-=1
		spent-=1
		return false
	return true

func capacity() -> int:
	return 4+int(ranks.cart)*2
