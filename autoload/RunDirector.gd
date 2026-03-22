extends Node

signal room_selected(room_data: Dictionary)
signal room_cleared(room_id: String)
signal reward_choices_generated(choices: Array)

const ROOMS_PATH := "res://data/rooms.json"
const REWARDS_PATH := "res://data/rewards.json"

@export var recent_room_memory: int = 3
@export var reward_choice_count: int = 2

var rng := RandomNumberGenerator.new()

var rooms: Array = []
var reward_pools: Dictionary = {}
var recent_room_ids: Array[String] = []

func _ready() -> void:
	rng.randomize()
	_load_data()


func _load_data() -> void:
	var rooms_json := _load_json(ROOMS_PATH)
	var rewards_json := _load_json(REWARDS_PATH)

	rooms = rooms_json.get("rooms", [])
	reward_pools = rewards_json.get("rewardPools", {})


func get_next_room(depth: int) -> Dictionary:
	var candidates := _filter_rooms_for_depth(depth)
	candidates = _remove_recent_repeats(candidates)

	if candidates.is_empty():
		candidates = _filter_rooms_for_depth(depth)

	var picked: Variant = WeightedPicker.pick_item(candidates, rng, "weight")
	if picked == null:
		push_warning("No room could be selected.")
		return {}

	var room_data: Dictionary = picked
	_track_recent_room(String(room_data.get("id", "")))
	emit_signal("room_selected", room_data)
	return room_data


func on_room_cleared(room_data: Dictionary) -> Array:
	var room_id := String(room_data.get("id", ""))
	emit_signal("room_cleared", room_id)

	var pool_name := String(room_data.get("onClearRewardPool", "standard"))
	var choices := _generate_reward_choices(pool_name, reward_choice_count)
	emit_signal("reward_choices_generated", choices)
	return choices


func _filter_rooms_for_depth(depth: int) -> Array:
	var out: Array = []
	for room in rooms:
		var min_d := int(room.get("minDepth", 1))
		var max_d := int(room.get("maxDepth", 999999))
		if depth >= min_d and depth <= max_d:
			out.append(room)
	return out


func _remove_recent_repeats(candidates: Array) -> Array:
	if recent_room_ids.is_empty():
		return candidates

	var out: Array = []
	for room in candidates:
		var id := String(room.get("id", ""))
		if not recent_room_ids.has(id):
			out.append(room)
	return out


func _track_recent_room(room_id: String) -> void:
	if room_id.is_empty():
		return
	recent_room_ids.append(room_id)
	while recent_room_ids.size() > recent_room_memory:
		recent_room_ids.pop_front()


func _generate_reward_choices(pool_name: String, count: int) -> Array:
	var pool: Array = reward_pools.get(pool_name, [])
	if pool.is_empty():
		pool = reward_pools.get("standard", [])

	var choices: Array = []
	var used_idx: Array[int] = []

	var safe_count := clampi(count, 1, max(1, pool.size()))
	while choices.size() < safe_count:
		var idx := WeightedPicker.pick_index(pool, rng, "weight")
		if idx < 0:
			break
		if used_idx.has(idx):
			continue
		used_idx.append(idx)

		var reward: Dictionary = pool[idx].duplicate(true)

		if reward.has("amount") and reward["amount"] is Array and reward["amount"].size() == 2:
			var arr: Array = reward["amount"]
			reward["amount"] = rng.randi_range(int(arr[0]), int(arr[1]))

		choices.append(reward)

	return choices


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing JSON file: %s" % path)
		return {}

	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Failed to open JSON file: %s" % path)
		return {}

	var text := f.get_as_text()
	var parsed := JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON object in: %s" % path)
		return {}

	return parsed
