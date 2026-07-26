class_name EnemyProjectileAttackData
extends Resource

@export_group("Projectile")
@export var projectile_scene: PackedScene
@export var projectile_data: ProjectileData
@export_range(0.0, 100.0, 1.0, "or_greater")
var muzzle_distance: float = 12.0

@export_group("Timing")
@export_range(0.05, 30.0, 0.05, "or_greater")
var cooldown: float = 1.35
@export_range(0.0, 30.0, 0.05, "or_greater")
var initial_delay: float = 0.45

@export_group("Positioning")
@export_range(1.0, 1000.0, 1.0, "or_greater")
var attack_range: float = 280.0
@export_range(1.0, 1000.0, 1.0, "or_greater")
var preferred_distance: float = 170.0
@export_range(0.0, 1000.0, 1.0, "or_greater")
var retreat_distance: float = 105.0
