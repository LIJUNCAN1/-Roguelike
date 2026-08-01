class_name RunProgression
extends Node

signal experience_changed(
	current_experience: int,
	experience_to_next_level: int,
	level: int
)
signal coins_changed(current_coins: int)
signal level_changed(level: int)

@export_range(1, 10000, 1, "or_greater")
var base_experience_to_level: int = 20
@export_range(1.0, 10.0, 0.05)
var experience_growth: float = 1.45
@export_range(0.0, 5.0, 0.01)
var damage_per_level: float = 0.05

var level: int = 1
var current_experience: int = 0
var coins: int = 0


func add_experience(amount: int) -> int:
	if amount <= 0:
		return 0

	current_experience += amount
	while current_experience >= get_experience_to_next_level():
		current_experience -= get_experience_to_next_level()
		level += 1
		level_changed.emit(level)
	experience_changed.emit(
		current_experience,
		get_experience_to_next_level(),
		level
	)
	return amount


func add_coins(amount: int) -> int:
	if amount <= 0:
		return 0
	coins += amount
	coins_changed.emit(coins)
	return amount


func spend_coins(amount: int) -> bool:
	if amount < 0 or coins < amount:
		return false
	coins -= amount
	coins_changed.emit(coins)
	return true


func get_experience_to_next_level() -> int:
	return maxi(
		int(round(base_experience_to_level * pow(
			experience_growth,
			level - 1
		))),
		1
	)


func modify_attack(attack_context: AttackContext) -> void:
	if attack_context == null or attack_context.projectile_data == null:
		return
	attack_context.projectile_data.damage *= (
		1.0 + damage_per_level * float(level - 1)
	)
	if level > 1:
		attack_context.add_tag(&"growth")


func reset() -> void:
	level = 1
	current_experience = 0
	coins = 0
	level_changed.emit(level)
	experience_changed.emit(
		current_experience,
		get_experience_to_next_level(),
		level
	)
	coins_changed.emit(coins)
