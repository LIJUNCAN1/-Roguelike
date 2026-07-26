class_name EnemyAttackData
extends Resource

@export_group("Attack")
@export_range(0.0, 1000000.0, 1.0, "or_greater")
var damage: float = 8.0
@export_range(1.0, 500.0, 1.0, "or_greater")
var attack_range: float = 22.0
@export_range(0.05, 30.0, 0.05, "or_greater")
var cooldown: float = 1.1
@export_range(0.0, 2000.0, 1.0, "or_greater")
var knockback_force: float = 130.0
@export_range(0.0, 2.0, 0.01, "or_greater")
var knockback_duration: float = 0.12
