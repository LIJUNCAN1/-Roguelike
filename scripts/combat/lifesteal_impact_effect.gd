class_name LifestealImpactEffect
extends ProjectileImpactEffect

@export_range(0.0, 10.0, 0.05, "or_greater")
var heal_ratio: float = 0.5
@export_range(0.0, 10000.0, 0.5, "or_greater")
var flat_healing: float = 0.0


func apply(impact_context: ImpactContext) -> void:
	if impact_context == null or impact_context.source_actor == null:
		return

	var health_component := impact_context.source_actor.get_node_or_null(
		"HealthComponent"
	) as HealthComponent
	if health_component == null:
		return

	var healing := (
		impact_context.damage_dealt * heal_ratio + flat_healing
	)
	health_component.heal(healing)
