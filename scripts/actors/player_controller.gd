extends CharacterBody2D

@export var character_data: CharacterData
@export_node_path("Node2D") var projectile_container_path: NodePath

@onready var movement_component: MovementComponent = $MovementComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var facing_marker: Polygon2D = $Visuals/FacingMarker
@onready var form_anchor: Node2D = $Visuals/FormAnchor
@onready var aim_origin: Marker2D = $AimOrigin
@onready var projectile_container: Node2D = get_node_or_null(
	projectile_container_path
) as Node2D

var facing_direction: Vector2 = Vector2.RIGHT
var movement_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	if character_data == null:
		push_error("Player requires a CharacterData resource.")
		return

	movement_component.configure(character_data.move_speed)
	health_component.configure(character_data.max_health)
	_update_facing_visual()


func apply_character_data(new_character_data: CharacterData) -> bool:
	if new_character_data == null:
		return false
	character_data = new_character_data
	movement_component.configure(character_data.move_speed)
	health_component.configure(character_data.max_health)
	return true


func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	movement_component.move(self, input_direction)

	if not input_direction.is_zero_approx():
		movement_direction = input_direction.normalized()

	aim_at(get_global_mouse_position())

	if Input.is_action_pressed("attack"):
		fire()


func aim_at(world_position: Vector2) -> void:
	var aim_vector := world_position - global_position
	if aim_vector.is_zero_approx():
		return

	facing_direction = aim_vector.normalized()
	_update_facing_visual()


func fire() -> Node2D:
	return weapon_component.try_fire(
		projectile_container,
		aim_origin.global_position,
		facing_direction
	)


func get_facing_direction() -> Vector2:
	return facing_direction


func get_movement_direction() -> Vector2:
	return movement_direction


func _update_facing_visual() -> void:
	var facing_angle := facing_direction.angle()
	facing_marker.rotation = facing_angle
	form_anchor.rotation = facing_angle
	aim_origin.position = (
		facing_direction * weapon_component.weapon_data.muzzle_distance
	)
