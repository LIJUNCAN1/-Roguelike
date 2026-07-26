class_name GravityPulseImpactEffect
extends ProjectileImpactEffect

@export_range(0.0, 1000.0, 1.0, "or_greater")
var radius: float = 105.0
@export_range(0.0, 10000.0, 0.5, "or_greater")
var damage: float = 4.0
@export_range(0.0, 1000.0, 1.0, "or_greater")
var pull_force: float = 135.0


func apply(impact_context: ImpactContext) -> void:
	if impact_context == null or impact_context.hurtbox == null:
		return
	var tree := impact_context.hurtbox.get_tree()
	for node in tree.get_nodes_in_group(&"room_enemies"):
		var enemy := node as EnemyController
		if enemy == null:
			continue
		var offset := impact_context.hit_position - enemy.global_position
		if offset.length() > radius:
			continue
		enemy.health_component.take_damage(
			damage,
			impact_context.source_actor
		)
		enemy.global_position += offset.limit_length(pull_force * 0.05)
