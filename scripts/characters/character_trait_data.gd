class_name CharacterTraitData
extends Resource

@export_group("Identity")
@export var id: StringName
@export var display_name: String
@export_multiline var description: String

@export_group("Original Life")
@export_range(1.0, 10.0, 0.05, "or_greater")
var fusion_damage_multiplier: float = 1.0

@export_group("Abyss Life")
@export_range(1.0, 10.0, 0.05, "or_greater")
var abyss_damage_multiplier: float = 1.0
@export_range(1.0, 10.0, 0.05, "or_greater")
var lifesteal_multiplier: float = 1.0
@export_range(1.0, 10.0, 0.05, "or_greater")
var control_duration_multiplier: float = 1.0

@export_group("Mechanical Life")
@export_range(0.0, 1000.0, 1.0, "or_greater")
var max_energy: float = 0.0
@export_range(0.0, 1000.0, 0.5, "or_greater")
var energy_regeneration: float = 0.0
@export_range(0.0, 1000.0, 1.0, "or_greater")
var powered_attack_cost: float = 0.0
@export_range(1.0, 10.0, 0.05, "or_greater")
var powered_attack_damage_multiplier: float = 1.0
