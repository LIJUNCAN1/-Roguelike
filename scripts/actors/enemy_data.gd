class_name EnemyData
extends Resource

@export_group("Identity")
@export var id: StringName
@export var display_name: String

@export_group("Movement")
@export_range(0.0, 1000.0, 1.0, "or_greater")
var move_speed: float = 70.0
@export_range(0.0, 200.0, 1.0, "or_greater")
var stopping_distance: float = 18.0
