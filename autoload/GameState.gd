extends Node

signal state_changed
signal player_died

var depth: int = 1
var hp: int = 100
var max_hp: int = 100
var currency: int = 0

var damage_mult: float = 1.0
var lifesteal_pct: float = 0.0

var active_powerups: Array[String] = []
var current_weapon: String = "sword"

func reset_run() -> void:
	depth = 1
	hp = 100
	max_hp = 100
	currency = 0
	damage_mult = 1.0
	lifesteal_pct = 0.0
	active_powerups.clear()
	current_weapon = "sword"
	emit_signal("state_changed")

func apply_damage(amount: int) -> void:
	hp = max(0, hp - amount)
	if hp <= 0:
		emit_signal("player_died")
	emit_signal("state_changed")

func heal(amount: int) -> void:
	hp = min(max_hp, hp + amount)
	emit_signal("state_changed")

func add_currency(amount: int) -> void:
	currency += amount
	emit_signal("state_changed")

func spend_currency(amount: int) -> bool:
	if currency < amount:
		return false
	currency -= amount
	emit_signal("state_changed")
	return true
