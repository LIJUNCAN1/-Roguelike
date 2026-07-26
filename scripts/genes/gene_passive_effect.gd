class_name GenePassiveEffect
extends Resource

@export_range(0.1, 10.0, 0.05, "or_greater")
var max_health_multiplier: float = 1.0
@export_range(0.1, 10.0, 0.05, "or_greater")
var movement_speed_multiplier: float = 1.0
@export_range(0.0, 10.0, 0.05, "or_greater")
var damage_taken_multiplier: float = 1.0
@export_range(0.0, 1000.0, 0.1, "or_greater")
var health_regeneration_per_second: float = 0.0
