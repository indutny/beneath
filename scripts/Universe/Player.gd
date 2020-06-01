extends Area
class_name Player

signal cargo_updated(player)
signal credits_updated(player)
signal map_updated(player)

export(float, 0, 1000) var max_total_cargo_weight = 100

var station: Station
var cargo = {}

# TODO(indutny): update inertia
var total_cargo_weight: float = 0

var credits: int = 0
	
# Persistence
func serialize():
	var pos = transform.origin
	return {
		"cargo": cargo,
		"credits": credits,
		"position": [ pos.x, pos.y, pos.z ]
	}

func deserialize(data):
	for resource_type in data["cargo"].keys():
		cargo[int(resource_type)] = int(data["cargo"][resource_type])
	credits = int(data["credits"])
	
	# Recompute weight
	total_cargo_weight = 0
	for resource_type in cargo.keys():
		var weight = Constants.RESOURCE_WEIGHT[resource_type]
		total_cargo_weight += weight * cargo[resource_type]
	
	if data.has("position"):
		var pos = data["position"]
		pos = Vector3(float(pos[0]), float(pos[1]), float(pos[2]))
		if not is_nan(pos.length()):
			transform.origin = pos
	
	emit_signal("cargo_updated", self)
	emit_signal("credits_updated", self)

func retrieve_cargo(resource_type: int, quantity: int) -> int:
	if not cargo.has(resource_type):
		return 0
	
	var max_quantity = cargo[resource_type]
	var change = clamp(quantity, 0, max_quantity)
	
	cargo[resource_type] -= change
	if cargo[resource_type] == 0:
		cargo.erase(resource_type)
		
	total_cargo_weight -= Constants.RESOURCE_WEIGHT[resource_type] * change
	emit_signal("cargo_updated", self)
	return change

func store_cargo(resource_type: int, quantity: int) -> int:
	var capacity = max_total_cargo_weight - total_cargo_weight
	capacity /= Constants.RESOURCE_WEIGHT[resource_type]
	capacity = floor(capacity)
	
	var to_store = clamp(quantity, 0, capacity)
	if to_store == 0:
		return to_store
	
	cargo[resource_type] = cargo.get(resource_type, 0) + to_store
	total_cargo_weight += to_store * Constants.RESOURCE_WEIGHT[resource_type]
	emit_signal("cargo_updated", self)
	return to_store
	
func add_credits(delta: int):
	credits += delta
	emit_signal("credits_updated", self)

func spend_credits(delta: int) -> bool:
	if credits < delta:
		return false
	credits -= delta
	emit_signal("credits_updated", self)
	return true

func get_map_locations() -> Array:
	return $MapArea.get_overlapping_areas()

func get_universe():
	return $"../"

func _on_MapArea_area_entered(_area):
	emit_signal("map_updated", self)
