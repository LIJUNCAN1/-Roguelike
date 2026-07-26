class_name CompanionData
extends Resource

@export_group("Identity")
@export var id: StringName
@export var display_name: String
@export_multiline var description: String

@export_group("Body")
@export var companion_scene: PackedScene
@export var follow_offset: Vector2 = Vector2(-28.0, 20.0)
@export_range(0.0, 1000.0, 1.0, "or_greater")
var move_speed: float = 180.0

@export_group("Combat")
@export var weapon_data: WeaponData
@export_range(0.0, 1000.0, 1.0, "or_greater")
var target_range: float = 240.0

@export_group("Build Link")
@export var linked_gene_id: StringName
@export_range(0.0, 10.0, 0.05, "or_greater")
var linked_gene_damage_multiplier: float = 1.0
