class_name FrameCharacterVisual
extends Node2D

const ASSET_ROOT := (
	"res://assets/sprites/player/preview_character/v1"
)
const FRAME_SIZE := Vector2i(64, 64)
const GROUND_ANCHOR_Y := 58
const ANIMATION_NAMES := [
	&"jump",
	&"slide",
	&"dodge",
	&"hurt",
	&"knockdown",
	&"heal",
	&"run_start",
	&"run_loop",
	&"run_stop",
]
const ACTION_ANIMATIONS := {
	&"dash": &"dodge",
	&"jump": &"jump",
	&"slide": &"slide",
	&"hurt": &"hurt",
	&"heal": &"heal",
	&"death": &"knockdown",
}

@export var base_evolution_id: StringName = &"base_life"
@export_range(0.25, 2.0, 0.01) var visual_scale := 1.0

@onready var actor := get_parent().get_parent() as CharacterBody2D
@onready var visual_root := get_parent() as Node2D
@onready var pose_root: Node2D = $PoseRoot
@onready var sprite: AnimatedSprite2D = $PoseRoot/Sprite
@onready var attack_slash: Line2D = $PoseRoot/AttackSlash
@onready var ghost_near: Sprite2D = $GhostNear
@onready var ghost_far: Sprite2D = $GhostFar
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
var action_elapsed := 0.0
var action_duration := 0.0
var facing_sign := -1.0
var is_dead := false
var is_base_form := true
var was_moving := false
var animation_durations: Dictionary[StringName, float] = {}
var last_health := -1.0
var last_max_health := -1.0


func _ready() -> void:
	_build_sprite_frames()
	sprite.animation_finished.connect(_on_animation_finished)
	_connect_actor_signals()
	if facing_marker != null:
		facing_marker.visible = false
	if evolution_system != null:
		evolution_system.evolution_changed.connect(
			_on_evolution_changed
		)
	sprite.play(&"idle")
	_align_sprite_to_ground()
	call_deferred("_sync_evolution_visibility")


func _process(delta: float) -> void:
	if not is_base_form:
		return
	_update_facing()
	var moving := actor.velocity.length_squared() > 4.0
	if not current_action.is_empty():
		action_elapsed += delta
		if (
			current_action != &"death"
			and action_elapsed >= action_duration
		):
			current_action = &""
			action_elapsed = 0.0
			_resume_locomotion(moving)
	else:
		_update_locomotion(moving)
	_apply_pose()
	was_moving = moving


func play_action(action: StringName, duration: float) -> void:
	if is_dead or duration <= 0.0:
		return
	current_action = action
	action_elapsed = 0.0
	action_duration = duration
	var animation := _get_action_animation(action)
	if not animation.is_empty():
		sprite.play(animation)
		_update_action_speed(animation, duration)


func play_heal() -> void:
	play_action(&"heal", 0.8)


func get_animation_frame_count(animation: StringName) -> int:
	if not sprite.sprite_frames.has_animation(animation):
		return 0
	return sprite.sprite_frames.get_frame_count(animation)


func get_animation_duration(animation: StringName) -> float:
	return animation_durations.get(animation, 0.0)


func _build_sprite_frames() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for animation: StringName in ANIMATION_NAMES:
		_add_asset_animation(frames, animation)
	_add_idle_animation(frames)
	sprite.sprite_frames = frames


func _add_asset_animation(
	frames: SpriteFrames,
	animation: StringName
) -> void:
	var folder := String(animation)
	var metadata_path := "%s/%s/metadata.json" % [
		ASSET_ROOT,
		folder,
	]
	var texture_path := "%s/%s/%s.png" % [
		ASSET_ROOT,
		folder,
		folder,
	]
	if (
		not FileAccess.file_exists(metadata_path)
		or not ResourceLoader.exists(texture_path)
	):
		push_error("Missing frame animation asset: %s" % animation)
		return
	var metadata_variant: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(metadata_path)
	)
	if not metadata_variant is Dictionary:
		push_error("Invalid frame metadata: %s" % metadata_path)
		return
	var metadata: Dictionary = metadata_variant as Dictionary
	var texture := load(texture_path) as Texture2D
	var frame_count := int(metadata.get("frame_count", 0))
	var durations: Array = metadata.get("durations_ms", []) as Array
	if texture == null or frame_count <= 0:
		push_error("Invalid frame sheet: %s" % texture_path)
		return
	frames.add_animation(animation)
	frames.set_animation_speed(animation, 1000.0)
	frames.set_animation_loop(
		animation,
		bool(metadata.get("loop", false))
	)
	var total_duration := 0.0
	for frame_index in frame_count:
		var atlas_frame := AtlasTexture.new()
		atlas_frame.atlas = texture
		atlas_frame.region = Rect2(
			Vector2(frame_index * FRAME_SIZE.x, 0),
			Vector2(FRAME_SIZE)
		)
		var duration_ms := (
			float(durations[frame_index])
			if frame_index < durations.size()
			else 50.0
		)
		frames.add_frame(
			animation,
			atlas_frame,
			maxf(duration_ms, 1.0)
		)
		total_duration += duration_ms / 1000.0
	animation_durations[animation] = total_duration


func _add_idle_animation(frames: SpriteFrames) -> void:
	if not frames.has_animation(&"jump"):
		return
	frames.add_animation(&"idle")
	frames.set_animation_speed(&"idle", 1.0)
	frames.set_animation_loop(&"idle", true)
	frames.add_frame(
		&"idle",
		frames.get_frame_texture(&"jump", 0),
		1.0
	)
	animation_durations[&"idle"] = 1.0


func _update_locomotion(moving: bool) -> void:
	if is_dead:
		return
	if moving:
		if not was_moving or sprite.animation == &"idle":
			sprite.play(&"run_start")
			sprite.speed_scale = 1.0
	else:
		if was_moving:
			sprite.play(&"run_stop")
			sprite.speed_scale = 1.0
		elif sprite.animation not in [&"idle", &"run_stop"]:
			sprite.play(&"idle")
			sprite.speed_scale = 1.0
	_align_sprite_to_ground()


func _resume_locomotion(moving: bool) -> void:
	if moving:
		sprite.play(&"run_loop")
	else:
		sprite.play(&"idle")
	sprite.speed_scale = 1.0
	_align_sprite_to_ground()


func _on_animation_finished() -> void:
	if not current_action.is_empty():
		return
	if sprite.animation == &"run_start":
		if actor.velocity.length_squared() > 4.0:
			sprite.play(&"run_loop")
		else:
			sprite.play(&"run_stop")
	elif sprite.animation == &"run_stop":
		sprite.play(&"idle")
	_align_sprite_to_ground()


func _align_sprite_to_ground() -> void:
	# AnimatedSprite2D is centred on the 64x64 canvas. The authored feet
	# anchor is y=58, so a centre at -26 places the feet on actor y=0.
	sprite.position = Vector2(
		0.0,
		float(FRAME_SIZE.y) * 0.5 - GROUND_ANCHOR_Y
	)


func _apply_pose() -> void:
	pose_root.position = Vector2.ZERO
	pose_root.rotation = 0.0
	pose_root.scale = Vector2.ONE * visual_scale
	pose_root.modulate = Color.WHITE
	attack_slash.visible = false
	ghost_near.visible = false
	ghost_far.visible = false
	if current_action == &"attack":
		_apply_attack_pose()
	elif not current_action.is_empty():
		var animation := _get_action_animation(current_action)
		if not animation.is_empty():
			_update_action_speed(animation, action_duration)


func _apply_attack_pose() -> void:
	var progress := clampf(action_elapsed / action_duration, 0.0, 1.0)
	var strike := sin(progress * PI)
	var direction := -facing_sign
	pose_root.position.x = direction * 3.5 * strike
	pose_root.rotation = direction * 0.10 * strike
	pose_root.scale = Vector2(
		visual_scale * (1.0 + strike * 0.055),
		visual_scale * (1.0 - strike * 0.035)
	)
	attack_slash.visible = progress > 0.10 and progress < 0.72
	attack_slash.position = Vector2(direction * 20.0, -29.0)
	attack_slash.scale.x = direction
	attack_slash.modulate.a = sin(
		clampf((progress - 0.10) / 0.62, 0.0, 1.0) * PI
	)


func _get_action_animation(action: StringName) -> StringName:
	return ACTION_ANIMATIONS.get(action, &"")


func _update_action_speed(
	animation: StringName,
	target_duration: float
) -> void:
	var source_duration := get_animation_duration(animation)
	if source_duration <= 0.0 or target_duration <= 0.0:
		sprite.speed_scale = 1.0
		return
	sprite.speed_scale = source_duration / target_duration


func _update_facing() -> void:
	if absf(actor.velocity.x) > 1.0:
		facing_sign = 1.0 if actor.velocity.x < 0.0 else -1.0
	elif current_action in [&"attack", &"dash", &"jump", &"slide"]:
		var direction := Vector2.ZERO
		if actor.has_method("get_facing_direction"):
			direction = actor.call("get_facing_direction") as Vector2
		if absf(direction.x) > 0.05:
			facing_sign = 1.0 if direction.x < 0.0 else -1.0
	# Source artwork faces left; mirroring supplies right-facing playback.
	sprite.flip_h = facing_sign < 0.0
	_align_sprite_to_ground()


func _connect_actor_signals() -> void:
	if actor.has_signal("attack_fired"):
		actor.connect("attack_fired", _on_attack_fired)
	if actor.has_signal("dash_started"):
		actor.connect("dash_started", _on_dash_started)
	if actor.has_signal("jump_started"):
		actor.connect("jump_started", _on_jump_started)
	if actor.has_signal("slide_started"):
		actor.connect("slide_started", _on_slide_started)
	var health := actor.get_node_or_null(
		"HealthComponent"
	) as HealthComponent
	if health != null:
		last_health = health.current_health
		last_max_health = health.max_health
		health.damaged.connect(_on_damaged)
		health.died.connect(_on_died)
		health.health_changed.connect(_on_health_changed)


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
	play_action(&"dash", 0.34)


func _on_jump_started(_direction: Vector2) -> void:
	var duration := 0.52
	var action_data := actor.get("action_data") as PlayerActionData
	if action_data != null:
		duration = action_data.jump_duration
	play_action(&"jump", duration)


func _on_slide_started(_direction: Vector2) -> void:
	var duration := 0.34
	var action_data := actor.get("action_data") as PlayerActionData
	if action_data != null:
		duration = action_data.slide_duration
	play_action(&"slide", duration)


func _on_damaged(
	_amount: float,
	_current_health: float,
	_source: Node
) -> void:
	play_action(&"hurt", 0.45)


func _on_health_changed(
	current_health: float,
	max_health: float
) -> void:
	if not is_equal_approx(max_health, last_max_health):
		last_health = current_health
		last_max_health = max_health
		return
	if current_health > last_health + 0.01:
		play_heal()
	last_health = current_health


func _on_died(_source: Node) -> void:
	is_dead = true
	current_action = &"death"
	action_elapsed = 0.0
	action_duration = maxf(
		get_animation_duration(&"knockdown"),
		0.8
	)
	sprite.play(&"knockdown")
	sprite.speed_scale = 1.0
