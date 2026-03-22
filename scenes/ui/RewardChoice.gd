extends Control

signal reward_picked(reward: Dictionary)

@onready var option_a_btn: Button = %OptionAButton
@onready var option_b_btn: Button = %OptionBButton
@onready var title_lbl: Label = %TitleLabel

var _choices: Array = []

func _ready() -> void:
	option_a_btn.pressed.connect(func(): _pick(0))
	option_b_btn.pressed.connect(func(): _pick(1))
	hide()

func show_choices(choices: Array) -> void:
	_choices = choices
	if _choices.size() < 2:
		push_warning("Need 2 reward choices.")
		return

	title_lbl.text = "Choose One Reward"
	option_a_btn.text = _reward_to_text(_choices[0])
	option_b_btn.text = _reward_to_text(_choices[1])
	show()

func _pick(index: int) -> void:
	if index < 0 or index >= _choices.size():
		return
	var reward: Dictionary = _choices[index]
	emit_signal("reward_picked", reward)
	hide()

func _reward_to_text(r: Dictionary) -> String:
	var kind := String(r.get("kind", "unknown"))
	match kind:
		"currency":
			return "+%s Gold" % str(r.get("amount", 0))
		"heal":
			return "Heal %s HP" % str(r.get("amount", 0))
		"max_hp_up":
			return "+%s Max HP" % str(r.get("amount", 0))
		"powerup":
			return "Power-up (%s)" % String(r.get("rarity", "common"))
		"weapon_mod":
			return "Weapon Mod (%s)" % String(r.get("rarity", "common"))
		"curse_boon":
			return "Curse/Boon (Random)"
		_:
			return "Mystery Reward"
