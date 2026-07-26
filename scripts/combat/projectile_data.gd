class_name ProjectileData
extends Resource

@export_group("Motion")
@export_range(0.0, 2000.0, 1.0, "or_greater")
var speed: float = 360.0
@export_range(0.05, 30.0, 0.05, "or_greater")
var lifetime: float = 1.5

@export_group("Impact")
@export_range(0.0, 100000.0, 1.0, "or_greater")
var damage: float = 10.0
@export_range(1, 100, 1, "or_greater")
var max_hits: int = 1
@export_range(0.0, 1.0, 0.01)
var critical_chance: float = 0.0
@export_range(1.0, 10.0, 0.05, "or_greater")
var critical_damage_multiplier: float = 2.0
@export_range(0.0, 20.0, 0.1, "or_greater")
var homing_strength: float = 0.0
@export_range(0.0, 2000.0, 1.0, "or_greater")
var homing_range: float = 240.0

@export_group("Appearance")
@export_range(1.0, 32.0, 0.5, "or_greater")
var radius: float = 3.0
@export var color: Color = Color(0.85, 1.0, 0.45, 1.0)
