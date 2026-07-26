class_name CombatFeedbackData
extends Resource

@export_group("Scenes")
@export var damage_number_scene: PackedScene
@export var death_effect_scene: PackedScene

@export_group("Hit")
@export var damage_number_color: Color = Color(1.0, 0.9, 0.4, 1.0)
@export var hit_flash_color: Color = Color.WHITE
@export_range(0.01, 1.0, 0.01, "or_greater")
var hit_flash_duration: float = 0.09
@export_range(0.0, 32.0, 0.5, "or_greater")
var visual_knockback_distance: float = 3.0

@export_group("Damage Number")
@export_range(0.0, 100.0, 1.0, "or_greater")
var damage_number_rise: float = 22.0
@export_range(0.05, 5.0, 0.05, "or_greater")
var damage_number_duration: float = 0.55

@export_group("Death")
@export var death_effect_color: Color = Color(1.0, 0.3, 0.4, 1.0)
@export_range(0.05, 5.0, 0.05, "or_greater")
var death_effect_duration: float = 0.3
