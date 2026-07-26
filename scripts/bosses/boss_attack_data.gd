class_name BossAttackData
extends Resource

@export_group("Identity")
@export var id: StringName
@export var display_name: String

@export_group("Timing")
@export_range(0.05, 30.0, 0.05, "or_greater")
var cooldown: float = 2.0
@export_range(0.05, 10.0, 0.05, "or_greater")
var telegraph_duration: float = 0.8

@export_group("Area")
@export_range(1.0, 1000.0, 1.0, "or_greater")
var trigger_range: float = 260.0
@export_range(1.0, 500.0, 1.0, "or_greater")
var radius: float = 48.0
@export_range(0.0, 1000000.0, 1.0, "or_greater")
var damage: float = 15.0
@export var warning_color: Color = Color(1.0, 0.25, 0.18, 1.0)
