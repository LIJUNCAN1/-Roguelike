class_name HitFeedbackComponent
extends Node

@export var feedback_data: CombatFeedbackData
@export_node_path("Node") var health_component_path: NodePath
@export_node_path("Node2D") var visual_root_path: NodePath
@export var flash_target_paths: Array[NodePath]

@onready var health_component: HealthComponent = get_node(
	health_component_path
) as HealthComponent
@onready var visual_root: Node2D = get_node(visual_root_path) as Node2D

var feedback_container: Node2D
var flash_targets: Array[Polygon2D] = []
var original_colors: Array[Color] = []
var visual_rest_position: Vector2
var hit_tween: Tween


func _ready() -> void:
	visual_rest_position = visual_root.position
	for target_path in flash_target_paths:
		var target := get_node(target_path) as Polygon2D
		flash_targets.append(target)
		original_colors.append(target.color)

	health_component.damaged.connect(_on_damaged)
	health_component.died.connect(_on_died)


func configure_container(container: Node2D) -> void:
	feedback_container = container


func _on_damaged(
	amount: float,
	_current_health: float,
	source: Node
) -> void:
	if feedback_data == null:
		return

	_spawn_damage_number(amount)
	_play_hit_reaction(_get_impact_direction(source))


func _on_died(_source: Node) -> void:
	if feedback_data == null:
		return
	_spawn_death_effect()


func _spawn_damage_number(amount: float) -> void:
	if (
		feedback_container == null
		or feedback_data.damage_number_scene == null
	):
		return

	var damage_number := (
		feedback_data.damage_number_scene.instantiate() as Node2D
	)
	damage_number.call(
		"setup",
		amount,
		feedback_data.damage_number_color
	)
	feedback_container.add_child(damage_number)
	damage_number.global_position = (
		get_parent().global_position + Vector2.UP * 14.0
	)
	damage_number.call(
		"play",
		feedback_data.damage_number_rise,
		feedback_data.damage_number_duration
	)


func _spawn_death_effect() -> void:
	if (
		feedback_container == null
		or feedback_data.death_effect_scene == null
	):
		return

	var death_effect := (
		feedback_data.death_effect_scene.instantiate() as Node2D
	)
	death_effect.call("setup", feedback_data.death_effect_color)
	feedback_container.add_child(death_effect)
	death_effect.global_position = get_parent().global_position
	death_effect.call("play", feedback_data.death_effect_duration)


func _play_hit_reaction(impact_direction: Vector2) -> void:
	if hit_tween != null and hit_tween.is_valid():
		hit_tween.kill()

	for index in flash_targets.size():
		flash_targets[index].color = feedback_data.hit_flash_color

	visual_root.position = (
		visual_rest_position
		+ impact_direction * feedback_data.visual_knockback_distance
	)

	hit_tween = create_tween()
	hit_tween.tween_property(
		visual_root,
		"position",
		visual_rest_position,
		feedback_data.hit_flash_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	for index in flash_targets.size():
		hit_tween.parallel().tween_property(
			flash_targets[index],
			"color",
			original_colors[index],
			feedback_data.hit_flash_duration
		)


func _get_impact_direction(source: Node) -> Vector2:
	if source != null and source.has_method("get_impact_direction"):
		return source.call("get_impact_direction") as Vector2
	return Vector2.ZERO
