class_name MetaUpgradeData
extends Resource

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export_range(1, 100, 1, "or_greater") var max_level: int = 5
@export_range(0, 1000000, 1, "or_greater") var base_cost: int = 5
@export_range(1.0, 10.0, 0.05, "or_greater")
var cost_growth: float = 1.6

@export_group("Per Level")
@export_range(0.0, 10.0, 0.01, "or_greater")
var max_health_bonus: float = 0.0
@export_range(0.0, 10.0, 0.01, "or_greater")
var movement_speed_bonus: float = 0.0
@export_range(0.0, 10.0, 0.01, "or_greater")
var attack_damage_bonus: float = 0.0
@export_range(0.0, 1.0, 0.01)
var critical_chance_bonus: float = 0.0
@export_range(0.0, 1.0, 0.01)
var damage_reduction: float = 0.0
@export_range(0.0, 10.0, 0.01, "or_greater")
var currency_gain_bonus: float = 0.0


func get_cost(level: int) -> int:
	return maxi(
		int(round(base_cost * pow(cost_growth, level))),
		1
	)
