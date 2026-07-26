class_name ImpactContext
extends RefCounted

var projectile: Projectile
var source_actor: Node
var hurtbox: HurtboxComponent
var hit_position: Vector2
var damage_dealt: float


func _init(
	hit_projectile: Projectile,
	attack_source: Node,
	target_hurtbox: HurtboxComponent,
	impact_position: Vector2,
	applied_damage: float
) -> void:
	projectile = hit_projectile
	source_actor = attack_source
	hurtbox = target_hurtbox
	hit_position = impact_position
	damage_dealt = applied_damage
