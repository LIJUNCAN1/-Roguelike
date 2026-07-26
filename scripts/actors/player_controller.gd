extends CharacterBody2D

@export var character_data: CharacterData

@onready var movement_component: MovementComponent = $MovementComponent
@onready var facing_marker: Polygon2D = $FacingMarker
@onready var aim_origin: Marker2D = $AimOrigin

var facing_direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	if character_data == null:
		push_error("Player requires a CharacterData resource.")
		return

	movement_component.configure(character_data.move_speed)
	_update_facing_visual()


func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	movement_component.move(self, input_direction)

	if not input_direction.is_zero_approx():
		facing_direction = input_direction.normalized()
		_update_facing_visual()


func get_facing_direction() -> Vector2:
	return facing_direction


func _update_facing_visual() -> void:
	var facing_angle := facing_direction.angle()
	facing_marker.rotation = facing_angle
	aim_origin.position = facing_direction * 10.0
