extends RefCounted
class_name WeightedPicker

static func pick_index(items: Array, rng: RandomNumberGenerator, weight_key: String = "weight") -> int:
	if items.is_empty():
		return -1

	var total_weight: float = 0.0
	for item in items:
		var w = float(item.get(weight_key, 0))
		if w > 0:
			total_weight += w

	if total_weight <= 0.0:
		return rng.randi_range(0, items.size() - 1)

	var roll := rng.randf_range(0.0, total_weight)
	var acc: float = 0.0

	for i in range(items.size()):
		var w = float(items[i].get(weight_key, 0))
		if w <= 0:
			continue
		acc += w
		if roll <= acc:
			return i

	return items.size() - 1


static func pick_item(items: Array, rng: RandomNumberGenerator, weight_key: String = "weight") -> Variant:
	var idx := pick_index(items, rng, weight_key)
	if idx < 0:
		return null
	return items[idx]
