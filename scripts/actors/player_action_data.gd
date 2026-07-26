class_name PlayerActionData
extends Resource

@export_group("Dash")
@export_range(1.0, 2000.0, 1.0, "or_greater")
var dash_speed: float = 420.0
@export_range(0.05, 2.0, 0.01, "or_greater")
var dash_duration: float = 0.16
@export_range(0.05, 10.0, 0.05, "or_greater")
var dash_cooldown: float = 0.75
@export_range(0.0, 5.0, 0.05, "or_greater")
var dash_invulnerability: float = 0.24
