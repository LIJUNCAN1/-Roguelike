class_name DamageOverTimeRunner
extends Node

var target_health: HealthComponent
var damage_source: Node
var tick_damage: float
var tick_interval: float
var tick_count: int


func setup(
	health: HealthComponent,
	source: Node,
	damage_per_tick: float,
	interval: float,
	count: int
) -> void:
	target_health = health
	damage_source = source
	tick_damage = maxf(damage_per_tick, 0.0)
	tick_interval = maxf(interval, 0.01)
	tick_count = maxi(count, 0)
	_run()


func _run() -> void:
	for _tick_index in tick_count:
		await get_tree().create_timer(tick_interval).timeout
		if not is_instance_valid(target_health) or target_health.is_dead:
			break
		target_health.take_damage(tick_damage, damage_source)
	queue_free()
