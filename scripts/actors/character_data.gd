class_name CharacterData
extends Resource

@export_group("Identity")
@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var base_evolution: EvolutionData
@export var trait_data: CharacterTraitData

@export_group("Survival")
@export_range(1.0, 1000000.0, 1.0, "or_greater")
var max_health: float = 100.0

@export_group("Movement")
@export_range(0.0, 1000.0, 1.0, "or_greater")
var move_speed: float = 120.0
