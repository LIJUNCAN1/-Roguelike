class_name SplitProjectileGeneEffect
extends GeneEffect

@export_range(2, 32, 1, "or_greater")
var projectile_count: int = 3
@export_range(0.0, 180.0, 0.5)
var spread_degrees: float = 14.0
@export var attack_tag: StringName = &"split"


func apply(attack_context: AttackContext) -> void:
	if attack_context == null or attack_context.directions.is_empty():
		return

	var base_directions: Array[Vector2] = (
		attack_context.directions.duplicate()
	)
	attack_context.directions.clear()
	var center_index := (projectile_count - 1) / 2.0

	for base_direction in base_directions:
		for projectile_index in projectile_count:
			var angle_offset := (
				(projectile_index - center_index) * spread_degrees
			)
			attack_context.directions.append(
				base_direction.rotated(deg_to_rad(angle_offset))
			)

	attack_context.add_tag(attack_tag)
