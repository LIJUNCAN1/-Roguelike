class_name ExplosionImpactEffect
extends ProjectileImpactEffect

@export_group("Damage")
@export_range(1.0, 500.0, 1.0, "or_greater")
var radius: float = 48.0
@export_range(0.0, 100000.0, 1.0, "or_greater")
var damage: float = 8.0

@export_group("Visual")
@export var effect_scene: PackedScene
@export var effect_color: Color = Color(1.0, 0.48, 0.12, 1.0)
@export_range(0.05, 5.0, 0.05, "or_greater")
var effect_duration: float = 0.28


func apply(impact_context: ImpactContext) -> void:
	if impact_context == null or impact_context.projectile == null:
		return

	var scene_tree := impact_context.projectile.get_tree()
	for node in scene_tree.get_nodes_in_group(&"damageable_hurtboxes"):
		var hurtbox := node as HurtboxComponent
		if hurtbox == null:
			continue

		if (
			hurtbox.global_position.distance_to(
				impact_context.hit_position
			)
			> radius
		):
			continue

		hurtbox.receive_damage(damage, impact_context.projectile)

	_spawn_effect(scene_tree, impact_context.hit_position)


func _spawn_effect(scene_tree: SceneTree, position: Vector2) -> void:
	if effect_scene == null:
		return

	var effect_parent := scene_tree.get_first_node_in_group(
		&"combat_effects"
	) as Node2D
	if effect_parent == null:
		return

	var effect := effect_scene.instantiate() as Node2D
	effect.call("setup", effect_color)
	effect_parent.add_child(effect)
	effect.global_position = position
	effect.call("play", radius, effect_duration)
