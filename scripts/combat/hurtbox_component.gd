class_name HurtboxComponent
extends Area2D

@export_node_path("Node") var health_component_path: NodePath

@onready var health_component: HealthComponent = get_node(
	health_component_path
) as HealthComponent


func receive_damage(amount: float, source: Node = null) -> bool:
	if health_component == null:
		push_error("HurtboxComponent requires a HealthComponent.")
		return false

	return health_component.take_damage(amount, source) > 0.0
