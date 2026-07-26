class_name HealthComponent
extends Node

signal health_changed(current_health: float, max_health: float)
signal damaged(
	amount: float,
	current_health: float,
	source: Node
)
signal died(source: Node)
signal damage_blocked(amount: float, source: Node)

@export_range(0.0, 5.0, 0.05, "or_greater")
var hit_invulnerability_duration: float = 0.0

var max_health: float = 1.0
var current_health: float = 1.0
var is_dead: bool = false
var invulnerability_remaining: float = 0.0


func _process(delta: float) -> void:
	invulnerability_remaining = maxf(
		invulnerability_remaining - delta,
		0.0
	)


func configure(new_max_health: float, refill: bool = true) -> void:
	max_health = maxf(new_max_health, 1.0)
	if refill:
		current_health = max_health
		is_dead = false
		invulnerability_remaining = 0.0
	else:
		current_health = minf(current_health, max_health)
	health_changed.emit(current_health, max_health)


func take_damage(amount: float, source: Node = null) -> float:
	if is_dead or amount <= 0.0:
		return 0.0
	if is_invulnerable():
		damage_blocked.emit(amount, source)
		return 0.0

	var applied_damage := minf(amount, current_health)
	current_health -= applied_damage
	if hit_invulnerability_duration > 0.0:
		grant_invulnerability(hit_invulnerability_duration)
	damaged.emit(applied_damage, current_health, source)
	health_changed.emit(current_health, max_health)

	if current_health <= 0.0:
		is_dead = true
		died.emit(source)

	return applied_damage


func grant_invulnerability(duration: float) -> void:
	invulnerability_remaining = maxf(
		invulnerability_remaining,
		duration
	)


func is_invulnerable() -> bool:
	return invulnerability_remaining > 0.0


func heal(amount: float) -> float:
	if is_dead or amount <= 0.0 or current_health >= max_health:
		return 0.0

	var applied_healing := minf(amount, max_health - current_health)
	current_health += applied_healing
	health_changed.emit(current_health, max_health)
	return applied_healing
