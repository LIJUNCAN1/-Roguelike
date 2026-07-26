class_name BossPhaseData
extends Resource

@export_group("Phase")
@export var display_name: String
@export_range(0.0, 1.0, 0.01)
var enter_health_ratio: float = 1.0

@export_group("Movement")
@export_range(0.0, 1000.0, 1.0, "or_greater")
var move_speed: float = 55.0
@export_range(0.0, 500.0, 1.0, "or_greater")
var preferred_distance: float = 110.0

@export_group("Combat")
@export var attack: BossAttackData

@export_group("Visual")
@export var body_color: Color = Color(0.68, 0.14, 0.32, 1.0)
@export var core_color: Color = Color(1.0, 0.42, 0.28, 1.0)
