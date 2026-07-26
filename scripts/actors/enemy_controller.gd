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


func _ready() -> void:
	if enemy_data == null:
		push_error("Enemy requires an EnemyData resource.")
		return

	movement_component.configure(enemy_data.move_speed)
	health_component.configure(enemy_data.max_health)
	health_component.died.connect(_on_died)
	hit_feedback_component.configure_container(
		get_node_or_null(feedback_container_path) as Node2D
	)
	target = get_node_or_null(target_path) as Node2D
	_update_facing_visual()


func _physics_process(delta: float) -> void:
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
		enemy_data.attack_data.damage,
		self
	)
	if damage_dealt <= 0.0:
		return

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


func _on_died(_source: Node) -> void:
	queue_free()
