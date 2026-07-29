class_name ModularCharacterVisual
extends Node2D

@export var base_evolution_id: StringName = &"base_life"
@export_range(0.05, 1.0, 0.01) var visual_scale: float = 0.16

@onready var actor := get_parent().get_parent() as CharacterBody2D
@onready var visual_root := get_parent() as Node2D
@onready var rig: Node2D = $Rig
@onready var root_bone: Node2D = $Rig/Skeleton2D/RootBone
@onready var body_bone: Node2D = $Rig/Skeleton2D/RootBone/BodyBone
@onready var head_bone: Node2D = $Rig/Skeleton2D/RootBone/HeadBone
@onready var hair_back_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/HairBackBone
)
@onready var hair_front_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/HairFrontBone
)
@onready var ear_back_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/EarBackBone
)
@onready var ear_front_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/EarFrontBone
)
@onready var scarf_bone: Node2D = $Rig/Skeleton2D/RootBone/ScarfBone
@onready var tail_bone: Node2D = $Rig/Skeleton2D/RootBone/TailBone
@onready var arm_back_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/ArmBackBone
)
@onready var arm_front_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/ArmFrontBone
)
@onready var leg_back_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/LegBackBone
)
@onready var leg_front_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/LegFrontBone
)
@onready var face_sprite: Sprite2D = (
	$Rig/Skeleton2D/RootBone/HeadBone/Face
)
@onready var evolution_system: EvolutionSystem = actor.get_node_or_null(
	"EvolutionSystem"
) as EvolutionSystem
@onready var pixel_presenter: PixelActorPresenter = actor.get_node_or_null(
	"PixelActorPresenter"
) as PixelActorPresenter
@onready var form_anchor := visual_root.get_node_or_null(
	"FormAnchor"
) as Node2D
@onready var facing_marker := visual_root.get_node_or_null(
	"FacingMarker"
) as CanvasItem

var current_action: StringName = &""
var action_elapsed: float = 0.0
var action_duration: float = 0.0
var locomotion_phase: float = 0.0
var facing_sign: float = -1.0
var is_dead: bool = false
var is_base_form: bool = true
var rest_positions: Dictionary = {}
var rest_rotations: Dictionary = {}
var part_sprites: Dictionary = {}
var idle_face: Texture2D
var attack_face: Texture2D
var hurt_face: Texture2D
var death_face: Texture2D


func _ready() -> void:
	_cache_rest_pose()
	_cache_parts()
	idle_face = preload(
		"res://assets/sprites/player/shadow_blade_parts/"
		+ "face_idle_left.png"
	)
	attack_face = preload(
		"res://assets/sprites/player/shadow_blade_parts/"
		+ "face_attack_left.png"
	)
	hurt_face = preload(
		"res://assets/sprites/player/shadow_blade_parts/"
		+ "face_hurt_left.png"
	)
	death_face = preload(
		"res://assets/sprites/player/shadow_blade_parts/"
		+ "face_death_left.png"
	)
	_connect_actor_signals()
	if facing_marker != null:
		facing_marker.visible = false
	if evolution_system != null:
		evolution_system.evolution_changed.connect(
			_on_evolution_changed
		)
	call_deferred("_sync_evolution_visibility")


func _process(delta: float) -> void:
	if not is_base_form:
		return
	_update_facing()
	var moving := actor.velocity.length_squared() > 4.0
	locomotion_phase += delta * (11.0 if moving else 3.2)
	if not current_action.is_empty():
		action_elapsed += delta
		if current_action != &"death" and action_elapsed >= action_duration:
			current_action = &""
			action_elapsed = 0.0
	_apply_pose(moving)


func set_part_texture(part_id: StringName, texture: Texture2D) -> bool:
	var sprite := part_sprites.get(part_id) as Sprite2D
	if sprite == null:
		return false
	sprite.texture = texture
	return true


func get_part_texture(part_id: StringName) -> Texture2D:
	var sprite := part_sprites.get(part_id) as Sprite2D
	return sprite.texture if sprite != null else null


func play_action(action: StringName, duration: float) -> void:
	if is_dead or duration <= 0.0:
		return
	current_action = action
	action_elapsed = 0.0
	action_duration = duration


func _connect_actor_signals() -> void:
	if actor.has_signal("attack_fired"):
		actor.connect("attack_fired", _on_attack_fired)
	if actor.has_signal("dash_started"):
		actor.connect("dash_started", _on_dash_started)
	var health := actor.get_node_or_null(
		"HealthComponent"
	) as HealthComponent
	if health != null:
		health.damaged.connect(_on_damaged)
		health.died.connect(_on_died)


func _cache_rest_pose() -> void:
	for bone in [
		root_bone,
		body_bone,
		head_bone,
		hair_back_bone,
		hair_front_bone,
		ear_back_bone,
		ear_front_bone,
		scarf_bone,
		tail_bone,
		arm_back_bone,
		arm_front_bone,
		leg_back_bone,
		leg_front_bone,
	]:
		rest_positions[bone] = bone.position
		rest_rotations[bone] = bone.rotation


func _cache_parts() -> void:
	for sprite in find_children("*", "Sprite2D", true, false):
		var part := sprite as Sprite2D
		part_sprites[StringName(part.name.to_snake_case())] = part


func _apply_pose(moving: bool) -> void:
	_reset_pose()
	var step := sin(locomotion_phase)
	var bounce := absf(step)
	if moving:
		root_bone.position.y -= bounce * 5.0
		body_bone.rotation = step * 0.035
		head_bone.position.y -= bounce * 1.8
		head_bone.rotation = -step * 0.025
		leg_front_bone.rotation = step * 0.24
		leg_back_bone.rotation = -step * 0.24
		arm_front_bone.rotation = -step * 0.16
		arm_back_bone.rotation = step * 0.16
		tail_bone.rotation += sin(locomotion_phase * 0.72) * 0.12
		scarf_bone.rotation += -0.08 - bounce * 0.04
	else:
		var breath := sin(locomotion_phase)
		root_bone.position.y -= breath * 1.5
		body_bone.scale = Vector2(1.0 + breath * 0.012, 1.0)
		head_bone.rotation = breath * 0.012
		tail_bone.rotation += breath * 0.09
		ear_back_bone.rotation -= breath * 0.025
		ear_front_bone.rotation += breath * 0.025
		hair_back_bone.rotation = -breath * 0.012
		scarf_bone.rotation += breath * 0.025

	_set_face(idle_face)
	match current_action:
		&"attack":
			_apply_attack_pose()
		&"dash":
			_apply_dash_pose()
		&"hurt":
			_apply_hurt_pose()
		&"death":
			_apply_death_pose()


func _reset_pose() -> void:
	rig.scale = Vector2(visual_scale * facing_sign, visual_scale)
	rig.position = Vector2.ZERO
	rig.rotation = 0.0
	for bone in rest_positions:
		var part := bone as Node2D
		part.position = rest_positions[bone]
		part.rotation = rest_rotations[bone]
		part.scale = Vector2.ONE


func _apply_attack_pose() -> void:
	var progress := clampf(action_elapsed / action_duration, 0.0, 1.0)
	var strike := sin(progress * PI)
	_set_face(attack_face)
	root_bone.rotation = -0.08 * strike
	root_bone.position.x -= 7.0 * strike
	arm_front_bone.rotation += 1.2 * strike
	arm_back_bone.rotation -= 0.42 * strike
	head_bone.rotation += 0.08 * strike
	scarf_bone.rotation -= 0.14 * strike


func _apply_dash_pose() -> void:
	var progress := clampf(action_elapsed / action_duration, 0.0, 1.0)
	var pulse := sin(progress * PI)
	root_bone.rotation = -0.17
	root_bone.position.x -= 10.0 * pulse
	root_bone.position.y += 3.0
	arm_front_bone.rotation += 0.48
	arm_back_bone.rotation += 0.36
	leg_front_bone.rotation -= 0.42
	leg_back_bone.rotation += 0.48
	tail_bone.rotation += 0.34
	scarf_bone.rotation -= 0.35


func _apply_hurt_pose() -> void:
	var progress := clampf(action_elapsed / action_duration, 0.0, 1.0)
	_set_face(hurt_face)
	root_bone.position.x += sin(progress * PI * 6.0) * 5.0
	root_bone.rotation = 0.12 * sin(progress * PI)
	arm_front_bone.rotation += 0.4
	arm_back_bone.rotation -= 0.32
	ear_front_bone.rotation += 0.16
	ear_back_bone.rotation -= 0.12


func _apply_death_pose() -> void:
	var progress := clampf(action_elapsed / 0.55, 0.0, 1.0)
	var eased := ease(progress, 1.8)
	_set_face(death_face)
	root_bone.rotation = lerpf(0.0, -PI * 0.48, eased)
	root_bone.position.y = lerpf(0.0, 45.0, eased)
	root_bone.position.x = lerpf(0.0, -8.0, eased)
	arm_front_bone.rotation += 0.65 * eased
	arm_back_bone.rotation -= 0.35 * eased
	tail_bone.rotation += 0.45 * eased


func _set_face(texture: Texture2D) -> void:
	if texture != null and face_sprite.texture != texture:
		face_sprite.texture = texture


func _update_facing() -> void:
	if absf(actor.velocity.x) > 1.0:
		facing_sign = 1.0 if actor.velocity.x < 0.0 else -1.0
		return
	if current_action in [&"attack", &"dash"]:
		var direction := Vector2.ZERO
		if actor.has_method("get_facing_direction"):
			direction = actor.call("get_facing_direction") as Vector2
		if absf(direction.x) > 0.05:
			facing_sign = 1.0 if direction.x < 0.0 else -1.0


func _sync_evolution_visibility() -> void:
	var evolution_id := base_evolution_id
	if (
		evolution_system != null
		and evolution_system.current_evolution != null
	):
		evolution_id = evolution_system.current_evolution.id
	_set_base_form_active(evolution_id == base_evolution_id)


func _set_base_form_active(active: bool) -> void:
	is_base_form = active
	visible = active
	if active:
		visual_root.visible = true
		if form_anchor != null:
			form_anchor.visible = false
		if pixel_presenter != null:
			pixel_presenter.sprite.visible = false
	elif form_anchor != null:
		form_anchor.visible = true


func _on_evolution_changed(
	_previous: EvolutionData,
	current: EvolutionData
) -> void:
	_set_base_form_active(
		current != null and current.id == base_evolution_id
	)


func _on_attack_fired(_projectile: Node2D) -> void:
	play_action(&"attack", 0.28)


func _on_dash_started(_direction: Vector2) -> void:
	play_action(&"dash", 0.22)


func _on_damaged(
	_amount: float,
	_current_health: float,
	_source: Node
) -> void:
	play_action(&"hurt", 0.28)


func _on_died(_source: Node) -> void:
	is_dead = true
	current_action = &"death"
	action_elapsed = 0.0
	action_duration = 999.0
