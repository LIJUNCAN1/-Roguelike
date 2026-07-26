class_name EnemyData
extends Resource

@export_group("Identity")
@export var id: StringName
@export var display_name: String
@export var visual_data: ActorVisualData

@export_group("Survival")
@export_range(1.0, 1000000.0, 1.0, "or_greater")
var max_health: float = 30.0

@export_group("Rewards")
@export_range(0, 10000, 1, "or_greater")
var experience_reward: int = 8
@export_range(0, 10000, 1, "or_greater")
var essence_reward: int = 3

@export_group("Movement")
@export_range(0.0, 1000.0, 1.0, "or_greater")
var move_speed: float = 70.0
@export_range(0.0, 200.0, 1.0, "or_greater")
var stopping_distance: float = 18.0

@export_group("Combat")
@export var attack_data: EnemyAttackData
