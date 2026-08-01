extends CharacterBody2D

signal dash_started(direction: Vector2)
signal jump_started(direction: Vector2)
signal slide_started(direction: Vector2)
signal attack_fired(projectile: Node2D)

@export var character_data: CharacterData
@export var action_data: PlayerActionData
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
@onready var input_bindings: InputBindingManager = get_node_or_null(
	"/root/InputBindings"
) as InputBindingManager

var facing_direction: Vector2 = Vector2.RIGHT
var movement_direction: Vector2 = Vector2.ZERO
var dash_direction: Vector2 = Vector2.RIGHT
var dash_remaining: float = 0.0
var dash_cooldown_remaining: float = 0.0
var jump_direction: Vector2 = Vector2.RIGHT
var jump_remaining: float = 0.0
var jump_cooldown_remaining: float = 0.0
var slide_direction: Vector2 = Vector2.RIGHT
var slide_remaining: float = 0.0
var slide_cooldown_remaining: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_remaining: float = 0.0
var input_enabled: bool = true


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


func _physics_process(delta: float) -> void:
	if not input_enabled:
		velocity = Vector2.ZERO
		return
	dash_cooldown_remaining = maxf(
		dash_cooldown_remaining - delta,
		0.0
	)
	jump_cooldown_remaining = maxf(
		jump_cooldown_remaining - delta,
		0.0
	)
	slide_cooldown_remaining = maxf(
		slide_cooldown_remaining - delta,
		0.0
	)
	if jump_remaining > 0.0:
		jump_remaining -= delta
		movement_component.move_at_speed(
			self,
			jump_direction,
			action_data.jump_speed
		)
		return
	if slide_remaining > 0.0:
		slide_remaining -= delta
		movement_component.move_at_speed(
			self,
			slide_direction,
			action_data.slide_speed
		)
		return
	if dash_remaining > 0.0:
		dash_remaining -= delta
		movement_component.move_at_speed(
			self,
			dash_direction,
			action_data.dash_speed
		)
		return
	if knockback_remaining > 0.0:
		knockback_remaining -= delta
		movement_component.move_at_speed(
			self,
			knockback_velocity.normalized(),
			knockback_velocity.length()
		)
		return

	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	movement_component.move(self, input_direction)

	if not input_direction.is_zero_approx():
		movement_direction = input_direction.normalized()
	if Input.is_action_just_pressed("jump"):
		start_jump(
			movement_direction
			if not movement_direction.is_zero_approx()
			else facing_direction
		)
		return
	if Input.is_action_just_pressed("slide"):
		start_slide(
			movement_direction
			if not movement_direction.is_zero_approx()
			else facing_direction
		)
		return
	if Input.is_action_just_pressed("dash"):
		start_dash(
			movement_direction
			if not movement_direction.is_zero_approx()
			else facing_direction
		)
		return

	var attack_direction := Input.get_vector(
		"attack_left",
		"attack_right",
		"attack_up",
		"attack_down"
	)
	if not attack_direction.is_zero_approx():
		facing_direction = attack_direction.normalized()
		_update_facing_visual()
		fire()


func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled
	if not input_enabled:
		velocity = Vector2.ZERO


func _update_aim_input() -> void:
	if (
		input_bindings == null
		or input_bindings.active_device
		!= InputBindingManager.DEVICE_GAMEPAD
	):
		aim_at(get_global_mouse_position())
		return
	var joypads := Input.get_connected_joypads()
	if not joypads.is_empty():
		var device_id: int = joypads[0]
		var stick_aim := Vector2(
			Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
		)
		if stick_aim.length_squared() >= 0.16:
			facing_direction = stick_aim.normalized()
			_update_facing_visual()
			return
	if not movement_direction.is_zero_approx():
		facing_direction = movement_direction
		_update_facing_visual()


func aim_at(world_position: Vector2) -> void:
	var aim_vector := world_position - global_position
	if aim_vector.is_zero_approx():
		return

	facing_direction = aim_vector.normalized()
	_update_facing_visual()


func fire() -> Node2D:
	var projectile := weapon_component.try_fire(
		projectile_container,
		aim_origin.global_position,
		facing_direction
	)
	if projectile != null:
		attack_fired.emit(projectile)
	return projectile


func start_dash(direction: Vector2) -> bool:
	if (
		action_data == null
		or dash_cooldown_remaining > 0.0
		or direction.is_zero_approx()
		or _has_active_movement_action()
	):
		return false
	dash_direction = direction.normalized()
	dash_remaining = action_data.dash_duration
	dash_cooldown_remaining = action_data.dash_cooldown
	health_component.grant_invulnerability(
		action_data.dash_invulnerability
	)
	dash_started.emit(dash_direction)
	return true


func start_jump(direction: Vector2) -> bool:
	if (
		action_data == null
		or jump_cooldown_remaining > 0.0
		or direction.is_zero_approx()
		or _has_active_movement_action()
	):
		return false
	jump_direction = direction.normalized()
	jump_remaining = action_data.jump_duration
	jump_cooldown_remaining = action_data.jump_cooldown
	health_component.grant_invulnerability(
		action_data.jump_invulnerability
	)
	jump_started.emit(jump_direction)
	return true


func start_slide(direction: Vector2) -> bool:
	if (
		action_data == null
		or slide_cooldown_remaining > 0.0
		or direction.is_zero_approx()
		or _has_active_movement_action()
	):
		return false
	slide_direction = direction.normalized()
	slide_remaining = action_data.slide_duration
	slide_cooldown_remaining = action_data.slide_cooldown
	health_component.grant_invulnerability(
		action_data.slide_invulnerability
	)
	slide_started.emit(slide_direction)
	return true


func _has_active_movement_action() -> bool:
	return (
		dash_remaining > 0.0
		or jump_remaining > 0.0
		or slide_remaining > 0.0
	)


func apply_knockback(
	direction: Vector2,
	force: float,
	duration: float = 0.12
) -> void:
	if direction.is_zero_approx() or force <= 0.0 or duration <= 0.0:
		return
	knockback_velocity = direction.normalized() * force
	knockback_remaining = duration


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
