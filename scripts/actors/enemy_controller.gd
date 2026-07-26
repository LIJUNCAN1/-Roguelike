class_name EnemyController
extends CharacterBody2D

@export var enemy_data: EnemyData
@export_node_path("Node2D") var target_path: NodePath

@onready var movement_component: MovementComponent = $MovementComponent
@onready var facing_marker: Polygon2D = $FacingMarker

var target: Node2D
var facing_direction: Vector2 = Vector2.LEFT


func _ready() -> void:
	if enemy_data == null:
		push_error("Enemy requires an EnemyData resource.")
		return

	movement_component.configure(enemy_data.move_speed)
	target = get_node_or_null(target_path) as Node2D
	_update_facing_visual()


func _physics_process(_delta: float) -> void:
	if target == null or not is_instance_valid(target):
		movement_component.move(self, Vector2.ZERO)
		return

	var target_offset := target.global_position - global_position
	if target_offset.length() <= enemy_data.stopping_distance:
		movement_component.move(self, Vector2.ZERO)
		return

	facing_direction = target_offset.normalized()
	_update_facing_visual()
	movement_component.move(self, facing_direction)


func set_target(new_target: Node2D) -> void:
	target = new_target


func get_facing_direction() -> Vector2:
	return facing_direction


func _update_facing_visual() -> void:
	facing_marker.rotation = facing_direction.angle()
