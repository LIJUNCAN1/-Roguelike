class_name MetaProgressionManager
extends Node

signal currency_changed(currency: int)
signal upgrade_changed(upgrade: MetaUpgradeData, level: int)
signal profile_reset

const DEFAULT_CATALOG_PATH := (
	"res://data/meta/meta_upgrade_catalog.tres"
)

var catalog: MetaUpgradeCatalog
var currency: int = 0
var upgrade_levels: Dictionary = {}
var save_path: String = "user://meta_progression.json"


func _ready() -> void:
	catalog = load(DEFAULT_CATALOG_PATH) as MetaUpgradeCatalog
	if DisplayServer.get_name() != "headless":
		load_profile()


func award_currency(base_amount: int) -> int:
	if base_amount <= 0:
		return 0
	var awarded := maxi(
		int(round(base_amount * get_currency_gain_multiplier())),
		1
	)
	currency += awarded
	currency_changed.emit(currency)
	save_profile()
	return awarded


func purchase_upgrade(upgrade_id: StringName) -> bool:
	if catalog == null:
		return false
	var upgrade := catalog.get_upgrade(upgrade_id)
	if upgrade == null:
		return false
	var level := get_upgrade_level(upgrade_id)
	if level >= upgrade.max_level:
		return false
	var cost := upgrade.get_cost(level)
	if currency < cost:
		return false
	currency -= cost
	level += 1
	upgrade_levels[String(upgrade_id)] = level
	currency_changed.emit(currency)
	upgrade_changed.emit(upgrade, level)
	save_profile()
	return true


func get_upgrade_level(upgrade_id: StringName) -> int:
	return int(upgrade_levels.get(String(upgrade_id), 0))


func get_upgrade_cost(upgrade_id: StringName) -> int:
	if catalog == null:
		return 0
	var upgrade := catalog.get_upgrade(upgrade_id)
	if upgrade == null:
		return 0
	return upgrade.get_cost(get_upgrade_level(upgrade_id))


func get_health_multiplier() -> float:
	return 1.0 + _sum_bonus(&"max_health_bonus")


func get_movement_multiplier() -> float:
	return 1.0 + _sum_bonus(&"movement_speed_bonus")


func get_damage_multiplier() -> float:
	return 1.0 + _sum_bonus(&"attack_damage_bonus")


func get_critical_chance_bonus() -> float:
	return _sum_bonus(&"critical_chance_bonus")


func get_damage_taken_multiplier() -> float:
	return clampf(
		1.0 - _sum_bonus(&"damage_reduction"),
		0.25,
		1.0
	)


func get_currency_gain_multiplier() -> float:
	return 1.0 + _sum_bonus(&"currency_gain_bonus")


func modify_attack(attack_context: AttackContext) -> void:
	if attack_context == null or attack_context.projectile_data == null:
		return
	var damage_multiplier := get_damage_multiplier()
	var critical_bonus := get_critical_chance_bonus()
	attack_context.projectile_data.damage *= damage_multiplier
	attack_context.projectile_data.critical_chance = clampf(
		attack_context.projectile_data.critical_chance + critical_bonus,
		0.0,
		1.0
	)
	if damage_multiplier > 1.0 or critical_bonus > 0.0:
		attack_context.add_tag(&"meta_evolution")


func save_profile() -> bool:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({
		"version": 1,
		"currency": currency,
		"upgrade_levels": upgrade_levels,
	}))
	return true


func load_profile() -> bool:
	if not FileAccess.file_exists(save_path):
		return false
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return false
	var data := parsed as Dictionary
	currency = maxi(int(data.get("currency", 0)), 0)
	upgrade_levels = data.get("upgrade_levels", {}) as Dictionary
	currency_changed.emit(currency)
	return true


func reset_profile(save_after: bool = true) -> void:
	currency = 0
	upgrade_levels.clear()
	currency_changed.emit(currency)
	profile_reset.emit()
	if save_after:
		save_profile()


func _sum_bonus(property_name: StringName) -> float:
	if catalog == null:
		return 0.0
	var total := 0.0
	for upgrade in catalog.upgrades:
		if upgrade == null:
			continue
		total += float(upgrade.get(property_name)) * (
			get_upgrade_level(upgrade.id)
		)
	return total
