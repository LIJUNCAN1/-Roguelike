class_name ModularCharacterVisual
extends Node2D

const REFERENCE_PART_SIZES := {
	&"tail": Vector2(150.0, 141.0),
	&"hair_back": Vector2(235.0, 238.0),
	&"arm_back_upper": Vector2(82.0, 101.0),
	&"arm_back_lower": Vector2(75.0, 95.0),
	&"hand_back": Vector2(50.0, 82.0),
	&"weapon_back": Vector2(155.0, 130.0),
	&"leg_back_upper": Vector2(94.0, 150.0),
	&"leg_back_lower": Vector2(70.0, 120.0),
	&"foot_back": Vector2(65.0, 72.0),
	&"torso": Vector2(176.0, 191.0),
	&"leg_front_upper": Vector2(94.0, 150.0),
	&"leg_front_lower": Vector2(70.0, 120.0),
	&"foot_front": Vector2(65.0, 72.0),
	&"face": Vector2(166.0, 176.0),
	&"ear_back": Vector2(85.0, 105.0),
	&"ear_front": Vector2(85.0, 105.0),
	&"hair_front": Vector2(254.0, 250.0),
	&"scarf_back": Vector2(190.0, 86.0),
	&"scarf_front": Vector2(190.0, 86.0),
	&"arm_front_upper": Vector2(82.0, 101.0),
	&"arm_front_lower": Vector2(75.0, 95.0),
	&"hand_front": Vector2(50.0, 82.0),
	&"weapon_front": Vector2(155.0, 130.0),
}
const REFERENCE_DRAW_LAYERS := {
	&"tail": -12,
	&"scarf_back": -11,
	&"weapon_back": -10,
	&"hand_back": -9,
	&"arm_back_lower": -9,
	&"arm_back_upper": -9,
	&"ear_back": -8,
	&"hair_back": -7,
	&"leg_back_upper": -6,
	&"leg_back_lower": -6,
	&"foot_back": -6,
	&"leg_front_upper": -5,
	&"leg_front_lower": -5,
	&"foot_front": -5,
	&"torso": -4,
	&"face": 0,
	&"ear_front": 1,
	&"hair_front": 2,
	&"scarf_front": 3,
	&"arm_front_upper": 4,
	&"arm_front_lower": 4,
	&"hand_front": 5,
	&"weapon_front": 6,
}
const WALK_POSES := [
	[0.28, -0.05, -0.22, 0.30, -0.18, 0.16, 0.18, -0.08],
	[0.18, 0.12, -0.14, 0.38, -0.12, 0.20, 0.12, -0.04],
	[0.02, 0.28, 0.04, 0.24, 0.00, 0.12, 0.00, 0.04],
	[-0.18, 0.34, 0.20, 0.08, 0.13, 0.02, -0.13, 0.10],
	[-0.25, 0.30, 0.28, -0.05, 0.18, -0.08, -0.18, 0.16],
	[-0.14, 0.38, 0.18, 0.12, 0.12, -0.04, -0.12, 0.20],
	[0.04, 0.24, 0.02, 0.28, 0.00, 0.04, 0.00, 0.12],
	[0.20, 0.08, -0.18, 0.34, -0.13, 0.10, 0.13, 0.02],
]

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
@onready var scarf_back_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/ScarfBackBone
)
@onready var scarf_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/ScarfBone
)
@onready var tail_bone: Node2D = $Rig/Skeleton2D/RootBone/TailBone
@onready var arm_back_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/ArmBackBone
)
@onready var arm_back_lower_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/ArmBackBone/ArmBackLowerBone
)
@onready var hand_back_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/ArmBackBone/ArmBackLowerBone/HandBackBone
)
@onready var arm_front_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/ArmFrontBone
)
@onready var arm_front_lower_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/ArmFrontBone/ArmFrontLowerBone
)
@onready var hand_front_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/ArmFrontBone/ArmFrontLowerBone/HandFrontBone
)
@onready var leg_back_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/LegBackBone
)
@onready var leg_back_lower_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/LegBackBone/LegBackLowerBone
)
@onready var foot_back_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/LegBackBone/LegBackLowerBone/FootBackBone
)
@onready var leg_front_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/LegFrontBone
)
@onready var leg_front_lower_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/LegFrontBone/LegFrontLowerBone
)
@onready var foot_front_bone: Node2D = (
	$Rig/Skeleton2D/RootBone/LegFrontBone/LegFrontLowerBone/FootFrontBone
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
	_apply_reference_part_scales()
	_apply_reference_draw_layers()
	idle_face = preload(
		"res://assets/sprites/player/shadow_blade_ai_parts/v1/"
		+ "face.png"
	)
	attack_face = idle_face
	hurt_face = idle_face
	death_face = idle_face
	rig.visible = true
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
	_fit_part_to_reference(part_id, sprite)
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
		scarf_back_bone,
		scarf_bone,
		tail_bone,
		arm_back_bone,
		arm_back_lower_bone,
		hand_back_bone,
		arm_front_bone,
		arm_front_lower_bone,
		hand_front_bone,
		leg_back_bone,
		leg_back_lower_bone,
		foot_back_bone,
		leg_front_bone,
		leg_front_lower_bone,
		foot_front_bone,
	]:
		rest_positions[bone] = bone.position
		rest_rotations[bone] = bone.rotation


func _cache_parts() -> void:
	for sprite in find_children("*", "Sprite2D", true, false):
		var part := sprite as Sprite2D
		part_sprites[StringName(part.name.to_snake_case())] = part


func _apply_reference_part_scales() -> void:
	for part_id in part_sprites:
		_fit_part_to_reference(
			part_id,
			part_sprites[part_id] as Sprite2D
		)


func _apply_reference_draw_layers() -> void:
	for part_id in REFERENCE_DRAW_LAYERS:
		var sprite := part_sprites.get(part_id) as Sprite2D
		if sprite != null:
			sprite.z_index = int(REFERENCE_DRAW_LAYERS[part_id])


func _fit_part_to_reference(
	part_id: StringName,
	sprite: Sprite2D
) -> void:
	if (
		sprite == null
		or sprite.texture == null
		or not REFERENCE_PART_SIZES.has(part_id)
	):
		return
	var texture_size := sprite.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var target_size := REFERENCE_PART_SIZES[part_id] as Vector2
	var fit_scale := minf(
		target_size.x / texture_size.x,
		target_size.y / texture_size.y
	)
	sprite.scale = Vector2.ONE * fit_scale


func _apply_pose(moving: bool) -> void:
	_reset_pose()
	if moving:
		_apply_walk_pose()
	else:
		var breath := sin(locomotion_phase)
		head_bone.rotation = breath * 0.012
		tail_bone.rotation += breath * 0.09
		ear_back_bone.rotation -= breath * 0.025
		ear_front_bone.rotation += breath * 0.025
		hair_back_bone.rotation = -breath * 0.012
		scarf_back_bone.rotation += breath * 0.018
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


func _apply_walk_pose() -> void:
	# Eight authored contact/passing poses are interpolated at 60 FPS. The
	# actor root never moves vertically, keeping collision and shadow stable.
	var pose_position := fposmod(
		locomotion_phase / TAU,
		1.0
	) * WALK_POSES.size()
	var pose_index := int(floorf(pose_position))
	var next_index := (pose_index + 1) % WALK_POSES.size()
	var blend := smoothstep(
		0.0,
		1.0,
		pose_position - pose_index
	)
	var pose: Array = WALK_POSES[pose_index]
	var next_pose: Array = WALK_POSES[next_index]
	var values: Array[float] = []
	for value_index in pose.size():
		values.append(
			lerpf(
				float(pose[value_index]),
				float(next_pose[value_index]),
				blend
			)
		)

	root_bone.rotation = -0.055 * facing_sign
	body_bone.rotation += sin(locomotion_phase * 2.0) * 0.012
	leg_front_bone.rotation += values[0]
	leg_front_lower_bone.rotation += values[1]
	leg_back_bone.rotation += values[2]
	leg_back_lower_bone.rotation += values[3]
	foot_front_bone.rotation -= values[0] + values[1] * 0.65
	foot_back_bone.rotation -= values[2] + values[3] * 0.65
	arm_front_bone.rotation += values[4]
	arm_front_lower_bone.rotation += values[5]
	arm_back_bone.rotation += values[6]
	arm_back_lower_bone.rotation += values[7]
	tail_bone.rotation += sin(locomotion_phase * 0.72) * 0.10
	scarf_back_bone.rotation -= 0.075
	scarf_bone.rotation -= 0.055


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
	root_bone.rotation = -0.06 * strike * facing_sign
	arm_front_bone.rotation += 0.68 * strike
	arm_front_lower_bone.rotation += 0.42 * strike
	hand_front_bone.rotation -= 0.12 * strike
	arm_back_bone.rotation -= 0.34 * strike
	arm_back_lower_bone.rotation += 0.20 * strike
	hand_back_bone.rotation += 0.08 * strike
	head_bone.rotation += 0.05 * strike
	scarf_back_bone.rotation -= 0.10 * strike
	scarf_bone.rotation -= 0.12 * strike


func _apply_dash_pose() -> void:
	var progress := clampf(action_elapsed / action_duration, 0.0, 1.0)
	var pulse := sin(progress * PI)
	root_bone.rotation = -0.17
	body_bone.rotation -= 0.05 * pulse
	arm_front_bone.rotation += 0.48 * pulse
	arm_front_lower_bone.rotation += 0.18 * pulse
	arm_back_bone.rotation += 0.36 * pulse
	arm_back_lower_bone.rotation += 0.14 * pulse
	leg_front_bone.rotation -= 0.42 * pulse
	leg_back_bone.rotation += 0.48 * pulse
	tail_bone.rotation += 0.34 * pulse
	scarf_back_bone.rotation -= 0.28 * pulse
	scarf_bone.rotation -= 0.35 * pulse


func _apply_hurt_pose() -> void:
	var progress := clampf(action_elapsed / action_duration, 0.0, 1.0)
	_set_face(hurt_face)
	root_bone.rotation = 0.12 * sin(progress * PI)
	arm_front_bone.rotation += 0.4
	arm_front_lower_bone.rotation += 0.18
	arm_back_bone.rotation -= 0.32
	arm_back_lower_bone.rotation -= 0.12
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
	arm_front_lower_bone.rotation += 0.25 * eased
	arm_back_bone.rotation -= 0.35 * eased
	arm_back_lower_bone.rotation -= 0.15 * eased
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
