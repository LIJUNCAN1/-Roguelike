class_name SlowEffectRunner
extends Node

var movement: MovementComponent
var original_speed: float
var remaining_duration: float


func setup(
	target_movement: MovementComponent,
	speed_multiplier: float,
	duration: float
) -> void:
	movement = target_movement
	original_speed = movement.move_speed
	movement.move_speed = original_speed * clampf(speed_multiplier, 0.05, 1.0)
	remaining_duration = maxf(duration, 0.01)


func refresh(speed_multiplier: float, duration: float) -> void:
	movement.move_speed = minf(
		movement.move_speed,
		original_speed * clampf(speed_multiplier, 0.05, 1.0)
	)
	remaining_duration = maxf(remaining_duration, duration)


func _process(delta: float) -> void:
	remaining_duration -= delta
	if remaining_duration > 0.0:
		return
	if is_instance_valid(movement):
		movement.move_speed = original_speed
	queue_free()
