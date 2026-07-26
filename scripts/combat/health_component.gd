class_name HealthComponent
extends Node

signal health_changed(current_health: float, max_health: float)
signal damaged(
	amount: float,
	current_health: float,
	source: Node
)
signal died(source: Node)

var max_health: float = 1.0
var current_health: float = 1.0
var is_dead: bool = false


func configure(new_max_health: float, refill: bool = true) -> void:
	max_health = maxf(new_max_health, 1.0)
	if refill:
		current_health = max_health
		is_dead = false
	else:
		current_health = minf(current_health, max_health)
	health_changed.emit(current_health, max_health)


func take_damage(amount: float, source: Node = null) -> float:
	if is_dead or amount <= 0.0:
		return 0.0

	var applied_damage := minf(amount, current_health)
	current_health -= applied_damage
	damaged.emit(applied_damage, current_health, source)
	health_changed.emit(current_health, max_health)

	if current_health <= 0.0:
		is_dead = true
		died.emit(source)

	return applied_damage
