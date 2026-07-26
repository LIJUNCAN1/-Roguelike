class_name HealthEventEffect
extends EventEffect

@export var amount: float = 0.0


func apply(context: EventContext) -> void:
	if context == null or context.health_component == null:
		return
	if amount >= 0.0:
		context.health_component.heal(amount)
	else:
		context.health_component.take_damage(-amount)
