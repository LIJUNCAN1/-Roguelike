class_name ChainLightningImpactEffect
extends ProjectileImpactEffect

@export_range(0.0, 1000.0, 1.0, "or_greater")
var chain_radius: float = 90.0
@export_range(0.0, 10000.0, 0.5, "or_greater")
var chain_damage: float = 6.0
@export_range(1, 20, 1, "or_greater")
var max_targets: int = 2


func apply(impact_context: ImpactContext) -> void:
	if impact_context == null or impact_context.hurtbox == null:
		return
	var primary_actor := impact_context.hurtbox.get_parent()
	var candidates: Array[Node2D] = []
	for node in primary_actor.get_tree().get_nodes_in_group(
		&"room_enemies"
	):
		if (
			node is Node2D
			and node != primary_actor
			and (node as Node2D).global_position.distance_to(
				impact_context.hit_position
			) <= chain_radius
		):
			candidates.append(node as Node2D)
	candidates.sort_custom(
		func(a: Node2D, b: Node2D) -> bool:
			return a.global_position.distance_squared_to(
				impact_context.hit_position
			) < b.global_position.distance_squared_to(
				impact_context.hit_position
			)
	)
	for index in mini(max_targets, candidates.size()):
		var health := candidates[index].get_node_or_null(
			"HealthComponent"
		) as HealthComponent
		if health != null:
			health.take_damage(
				chain_damage,
				impact_context.source_actor
			)
