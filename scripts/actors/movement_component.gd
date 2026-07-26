class_name MovementComponent
extends Node

var move_speed: float = 0.0


func configure(speed: float) -> void:
	move_speed = maxf(speed, 0.0)


func move(body: CharacterBody2D, direction: Vector2) -> void:
	move_at_speed(body, direction, move_speed)


func move_at_speed(
	body: CharacterBody2D,
	direction: Vector2,
	speed: float
) -> void:
	body.velocity = direction.limit_length(1.0) * maxf(speed, 0.0)
	body.move_and_slide()
