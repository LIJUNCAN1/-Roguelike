class_name SlowImpactEffect
extends ProjectileImpactEffect

@export_range(0.05, 1.0, 0.05)
var speed_multiplier: float = 0.55
@export_range(0.01, 60.0, 0.05, "or_greater")
var duration: float = 1.5


func apply(impact_context: ImpactContext) -> void:
	if impact_context == null or impact_context.hurtbox == null:
		return

	var actor := impact_context.hurtbox.get_parent()
	var movement := actor.get_node_or_null("MovementComponent") as MovementComponent
	if movement == null:
		return

	var runner := actor.get_node_or_null("SlowEffectRunner") as SlowEffectRunner
	if runner != null:
		runner.refresh(speed_multiplier, duration)
		return

	runner = SlowEffectRunner.new()
	runner.name = "SlowEffectRunner"
	actor.add_child(runner)
	runner.setup(movement, speed_multiplier, duration)
