class_name AttackContext
extends RefCounted

var projectile_scene: PackedScene
var projectile_data: ProjectileData
var directions: Array[Vector2] = []
var tags: Array[StringName] = []
var impact_effects: Array[ProjectileImpactEffect] = []


func _init(
	base_projectile_scene: PackedScene,
	base_projectile_data: ProjectileData,
	base_direction: Vector2
) -> void:
	projectile_scene = base_projectile_scene
	projectile_data = base_projectile_data.duplicate(true) as ProjectileData
	if not base_direction.is_zero_approx():
		directions.append(base_direction.normalized())


func add_tag(tag: StringName) -> void:
	if not tag.is_empty() and not tags.has(tag):
		tags.append(tag)


func has_tag(tag: StringName) -> bool:
	return tags.has(tag)


func add_impact_effect(effect: ProjectileImpactEffect) -> void:
	if effect != null:
		impact_effects.append(effect)
