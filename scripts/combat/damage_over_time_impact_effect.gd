class_name DamageOverTimeImpactEffect
extends ProjectileImpactEffect

@export_range(0.0, 1000.0, 0.5, "or_greater")
var tick_damage: float = 2.0
@export_range(0.01, 60.0, 0.05, "or_greater")
var tick_interval: float = 0.5
@export_range(1, 100, 1, "or_greater")
var tick_count: int = 3


func apply(impact_context: ImpactContext) -> void:
	if impact_context == null or impact_context.hurtbox == null:
		return

	var health := impact_context.hurtbox.health_component
	if health == null or health.is_dead:
		return

	var runner := DamageOverTimeRunner.new()
	health.add_child(runner)
	runner.setup(
		health,
		impact_context.source_actor,
		tick_damage,
		tick_interval,
		tick_count
	)
