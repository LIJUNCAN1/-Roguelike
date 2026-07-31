class_name EnemyController
extends CharacterBody2D

signal attack_performed(damage: float, target: Node2D)

@export var enemy_data: EnemyData
@export_node_path("Node2D") var target_path: NodePath
@export_node_path("Node2D") var feedback_container_path: NodePath

@onready var movement_component: MovementComponent = $MovementComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var hit_feedback_component: HitFeedbackComponent = (
	$HitFeedbackComponent
)
@onready var facing_marker: Polygon2D = $Visuals/FacingMarker

var target: Node2D
var projectile_container: Node2D
var facing_direction: Vector2 = Vector2.LEFT
var contact_cooldown_remaining: float = 0.0
var difficulty_multiplier: float = 1.0
var is_dying: bool = false


func _ready() -> void:
	if enemy_data == null:
		push_error("Enemy requires an EnemyData resource.")
		return

	movement_component.configure(enemy_data.move_speed)
	var pixel_presenter := get_node_or_null(
		"PixelActorPresenter"
	) as PixelActorPresenter
	if pixel_presenter != null:
		pixel_presenter.configure(
			null if enemy_data.animation_set != null else enemy_data.visual_data
		)
	var animation_presenter := get_node_or_null(
		"EnemyAnimationPresenter"
	) as EnemyAnimationPresenter
	if animation_presenter != null:
		animation_presenter.configure(enemy_data.animation_set)
	health_component.configure(enemy_data.max_health)
	health_component.died.connect(_on_died)
	hit_feedback_component.configure_container(
		get_node_or_null(feedback_container_path) as Node2D
	)
	target = get_node_or_null(target_path) as Node2D
	_update_facing_visual()


func _physics_process(delta: float) -> void:
	if is_dying:
		velocity = Vector2.ZERO
		return
	contact_cooldown_remaining = maxf(
		contact_cooldown_remaining - delta,
		0.0
	)
	if target == null or not is_instance_valid(target):
		movement_component.move(self, Vector2.ZERO)
		return

	var target_offset := target.global_position - global_position
	var target_distance := target_offset.length()
	if not target_offset.is_zero_approx():
		facing_direction = target_offset.normalized()
		_update_facing_visual()

	if (
		enemy_data.attack_data != null
		and target_distance <= enemy_data.attack_data.attack_range
	):
		movement_component.move(self, Vector2.ZERO)
		_try_contact_attack()
		return

	if target_distance <= enemy_data.stopping_distance:
		movement_component.move(self, Vector2.ZERO)
		return

	movement_component.move(self, facing_direction)


func set_target(new_target: Node2D) -> void:
	target = new_target


func set_feedback_container(container: Node2D) -> void:
	hit_feedback_component.configure_container(container)


func set_projectile_container(container: Node2D) -> void:
	projectile_container = container


func get_facing_direction() -> Vector2:
	return facing_direction


func apply_difficulty(multiplier: float) -> void:
	difficulty_multiplier = maxf(multiplier, 1.0)
	health_component.configure(
		enemy_data.max_health * difficulty_multiplier
	)
	movement_component.configure(
		enemy_data.move_speed * lerpf(
			1.0,
			difficulty_multiplier,
			0.25
		)
	)


func _update_facing_visual() -> void:
	facing_marker.rotation = facing_direction.angle()


func _try_contact_attack() -> void:
	if (
		contact_cooldown_remaining > 0.0
		or enemy_data.attack_data == null
	):
		return
	var target_health := target.get_node_or_null(
		"HealthComponent"
	) as HealthComponent
	if target_health == null:
		return
	var damage_dealt := target_health.take_damage(
		enemy_data.attack_data.damage * difficulty_multiplier,
		self
	)
	if damage_dealt <= 0.0:
		return

	if target.has_method("apply_knockback"):
		target.call(
			"apply_knockback",
			(target.global_position - global_position).normalized(),
			enemy_data.attack_data.knockback_force,
			enemy_data.attack_data.knockback_duration
		)
	contact_cooldown_remaining = enemy_data.attack_data.cooldown
	_play_attack_pulse()
	attack_performed.emit(damage_dealt, target)


func _play_attack_pulse() -> void:
	facing_marker.scale = Vector2.ONE
	var tween := create_tween()
	tween.tween_property(
		facing_marker,
		"scale",
		Vector2.ONE * 1.8,
		0.06
	)
	tween.tween_property(
		facing_marker,
		"scale",
		Vector2.ONE,
		0.12
	)


func _on_died(source: Node) -> void:
	if is_dying:
		return
	is_dying = true
	set_physics_process(false)
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	var hurtbox := get_node_or_null("HurtboxComponent") as Area2D
	if hurtbox != null:
		hurtbox.set_deferred("monitorable", false)
	var reward_owner := _resolve_reward_owner(source)
	if reward_owner != null:
		var progression := reward_owner.get_node_or_null(
			"RunProgression"
		) as RunProgression
		if progression != null:
			progression.add_experience(enemy_data.experience_reward)
			progression.add_essence(enemy_data.essence_reward)
	var animation_presenter := get_node_or_null(
		"EnemyAnimationPresenter"
	) as EnemyAnimationPresenter
	var delay := 0.0
	if animation_presenter != null:
		delay = animation_presenter.get_death_duration()
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	queue_free()


func _resolve_reward_owner(source: Node) -> Node:
	if source == null:
		return null
	var owner := source
	if source is Projectile:
		var source_actor: Node = (source as Projectile).source_actor
		if source_actor != null:
			owner = source_actor
	if owner.has_method("get_reward_owner"):
		var resolved: Node = owner.call("get_reward_owner") as Node
		if resolved != null:
			owner = resolved
	return owner
