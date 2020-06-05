extends Area
class_name Player

signal cargo_updated(player)
signal credits_updated(player)
signal map_updated(player)

export(float, 0, 1000) var max_total_cargo_weight = 1000
export(float, 0, 1000) var max_fuel = 100

var station: Station
var burn_accumulator: float = 0

# Start with full fuel tank
var cargo = { Constants.ResourceType.Fuel: max_fuel }

# TODO(indutny): update inertia
var total_cargo_weight: float = 0

var credits: int = 0

# Persistence
func serialize():
	var pos = to_global(Vector3())
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
			global_translate(pos - to_global(Vector3()))
	
	emit_signal("cargo_updated", self)
	emit_signal("credits_updated", self)

func retrieve_cargo(resource_type: int, quantity: int) -> int:
	assert(quantity >= 0)
	if quantity == 0:
		return 0
	
	if not cargo.has(resource_type):
		return 0
	
	var max_quantity = cargo[resource_type]
	
	# TODO(indutny): stop using clamp for ints
	var change: int = int(clamp(quantity, 0, max_quantity))
	
	cargo[resource_type] -= change
	if cargo[resource_type] == 0:
		cargo.erase(resource_type)
		
	total_cargo_weight -= Constants.RESOURCE_WEIGHT[resource_type] * change
	emit_signal("cargo_updated", self)
	return change

func burn_fuel(distance: float):
	assert(distance >= 0)
	var universe_distance: float = distance / get_universe().universe_scale
	var quantity: float = universe_distance * Constants.FUEL_PER_UNIVERSE_UNIT
	
	burn_accumulator += quantity
	if burn_accumulator < 1:
		return
	
	var to_burn: int = int(floor(burn_accumulator))
	burn_accumulator -= float(to_burn)
	var burned = retrieve_cargo(Constants.ResourceType.Fuel, to_burn)
	if burned != to_burn:
		credits -= int(max(to_burn - burned, 0) * Constants.FUEL_LOAN_PRICE)
		credits = int(max(-Constants.FUEL_MAX_LOAN, credits))
		emit_signal("credits_updated", self)

func store_cargo(resource_type: int, quantity: int) -> int:
	assert(quantity >= 0)
	if quantity == 0:
		return 0
	
	var density = Constants.RESOURCE_WEIGHT[resource_type]
	
	# Can't store in cargo (see Constants.gd)
	if density < 0:
		return 0

	var capacity
	
	# Store fuel alongside regular cargo, but use different capacity
	if resource_type == Constants.ResourceType.Fuel:
		assert(density == 0)
		capacity = max_fuel - cargo.get(resource_type, 0)
	else:
		capacity = max_total_cargo_weight - total_cargo_weight
		capacity /= density
		capacity = floor(capacity)
	
	var to_store: int = int(clamp(quantity, 0, capacity))
	if to_store == 0:
		return to_store
	
	cargo[resource_type] = cargo.get(resource_type, 0) + to_store
	total_cargo_weight += to_store * density
	emit_signal("cargo_updated", self)
	return to_store
	
func has_cargo_dict(dict: Dictionary) -> bool:
	for key in dict.keys():
		if cargo.get(key, 0) < dict[key]:
			return false
	return true

func retrieve_cargo_dict(dict: Dictionary) -> Dictionary:
	var out = {}
	for key in dict.keys():
		out[key] = retrieve_cargo(key, dict[key])
	return out
	
func add_credits(delta: int):
	assert(delta >= 0)
	if delta == 0:
		return
	credits += int(max(0, delta))
	emit_signal("credits_updated", self)

func spend_credits(delta: int) -> bool:
	if delta == 0:
		return true
	
	assert(delta >= 0)
	if credits < delta:
		return false
	credits -= int(max(0, delta))
	emit_signal("credits_updated", self)
	return true

func has_credits(value: int) -> bool:
	return value <= credits

func get_map_locations() -> Array:
	# TODO(indutny): can it be done more efficiently?
	var list = $MapArea.get_overlapping_areas()
	var filtered = []
	for x in list:
		if x != self:
			filtered.append(x)
	
	# Always show at least one location
	if len(filtered) == 0:
		return [ $"../".get_default_map_location() ]
	return filtered

func get_universe():
	return $"../"

func _on_MapArea_area_entered(_area):
	emit_signal("map_updated", self)
