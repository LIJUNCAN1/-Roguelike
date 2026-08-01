class_name FrameCharacterVisual
extends Node2D

const ASSET_ROOT := (
	"res://assets/sprites/player/seed_slime/v1"
)
const FRAME_SIZE := Vector2i(48, 48)
const GROUND_ANCHOR_Y := 44
const ANIMATION_NAMES := [
	&"idle",
	&"jump",
	&"slide",
	&"dodge",
	&"hurt",
	&"knockdown",
	&"heal",
	&"run_start",
	&"run_loop",
	&"run_stop",
	&"run_side",
	&"run_up",
	&"run_down",
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
@export_range(0.25, 2.0, 0.01) var visual_scale := 1.25
@export_range(2.0, 24.0, 1.0) var dash_trail_near_distance := 7.0
@export_range(4.0, 40.0, 1.0) var dash_trail_far_distance := 14.0
@export_range(0.0, 1.0, 0.01) var dash_trail_near_alpha := 0.42
@export_range(0.0, 1.0, 0.01) var dash_trail_far_alpha := 0.2

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
var locked_action_direction := Vector2.ZERO
var facing_sign := -1.0
var is_dead := false
var is_base_form := true
var was_moving := false
var animation_durations: Dictionary[StringName, float] = {}
var animation_frame_sizes: Dictionary[StringName, Vector2i] = {}
var animation_ground_anchors: Dictionary[StringName, int] = {}
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
	var moving := actor.velocity.length_squared() > 4.0
	if not current_action.is_empty():
		action_elapsed += delta
		if (
			current_action != &"death"
			and action_elapsed >= action_duration
		):
			var completed_action := current_action
			current_action = &""
			action_elapsed = 0.0
			if completed_action == &"dash":
				locked_action_direction = Vector2.ZERO
			_resume_locomotion(moving)
	else:
		_update_locomotion(moving)
	_update_facing()
	_apply_pose()
	was_moving = moving


func play_action(
	action: StringName,
	duration: float,
	direction: Vector2 = Vector2.ZERO
) -> void:
	if is_dead or duration <= 0.0:
		return
	if action == &"dash" and not direction.is_zero_approx():
		locked_action_direction = direction.normalized()
	current_action = action
	action_elapsed = 0.0
	action_duration = duration
	var animation := _get_action_animation(action)
	if not animation.is_empty():
		sprite.play(animation)
		_update_action_speed(animation, duration)
		_align_sprite_to_ground()


func play_heal() -> void:
	play_action(&"heal", 0.8)


func play_use_item_or_skill() -> void:
	play_heal()


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
	_add_idle_fallback(frames)
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
	var frame_size := FRAME_SIZE
	var frame_size_variant: Variant = metadata.get("frame_size", [])
	if frame_size_variant is Array:
		var frame_size_data := frame_size_variant as Array
		if frame_size_data.size() >= 2:
			frame_size = Vector2i(
				int(frame_size_data[0]),
				int(frame_size_data[1])
			)
	if (
		texture == null
		or frame_count <= 0
		or frame_size.x <= 0
		or frame_size.y <= 0
		or texture.get_width() < frame_size.x * frame_count
		or texture.get_height() < frame_size.y
	):
		push_error("Invalid frame sheet: %s" % texture_path)
		return
	animation_frame_sizes[animation] = frame_size
	animation_ground_anchors[animation] = int(
		metadata.get("ground_anchor_y", GROUND_ANCHOR_Y)
	)
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
			Vector2(frame_index * frame_size.x, 0),
			Vector2(frame_size)
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


func _add_idle_fallback(frames: SpriteFrames) -> void:
	if frames.has_animation(&"idle"):
		return
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
	animation_frame_sizes[&"idle"] = animation_frame_sizes.get(
		&"jump",
		FRAME_SIZE
	)
	animation_ground_anchors[&"idle"] = animation_ground_anchors.get(
		&"jump",
		GROUND_ANCHOR_Y
	)
	animation_durations[&"idle"] = 1.0


func _update_locomotion(moving: bool) -> void:
	if is_dead:
		return
	if moving:
		var run_animation := _get_directional_run_animation()
		if sprite.animation != run_animation:
			sprite.play(run_animation)
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
		sprite.play(_get_directional_run_animation())
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
	# AnimatedSprite2D is centred on the authored frame. Moving the frame's
	# ground anchor to actor y=0 keeps every animation stable while moving.
	var frame_size: Vector2i = animation_frame_sizes.get(
		sprite.animation,
		FRAME_SIZE
	)
	var ground_anchor_y: int = animation_ground_anchors.get(
		sprite.animation,
		GROUND_ANCHOR_Y
	)
	sprite.position = Vector2(
		0.0,
		float(frame_size.y) * 0.5 - ground_anchor_y
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
	elif current_action == &"dash":
		_apply_dash_trail()
	elif not current_action.is_empty():
		var animation := _get_action_animation(current_action)
		if not animation.is_empty():
			_update_action_speed(animation, action_duration)


func _apply_dash_trail() -> void:
	var direction := _get_dash_direction()
	if direction.is_zero_approx() or action_duration <= 0.0:
		return
	var progress := clampf(action_elapsed / action_duration, 0.0, 1.0)
	var strength := sin(progress * PI)
	if strength <= 0.01:
		return
	var frame_count := sprite.sprite_frames.get_frame_count(sprite.animation)
	var near_frame := maxi(sprite.frame - 1, 0)
	var far_frame := maxi(sprite.frame - 2, 0)
	if frame_count <= 0:
		return
	_configure_dash_ghost(
		ghost_near,
		near_frame,
		direction,
		dash_trail_near_distance,
		dash_trail_near_alpha * strength
	)
	_configure_dash_ghost(
		ghost_far,
		far_frame,
		direction,
		dash_trail_far_distance,
		dash_trail_far_alpha * strength
	)


func _configure_dash_ghost(
	ghost: Sprite2D,
	frame_index: int,
	direction: Vector2,
	distance: float,
	alpha: float
) -> void:
	ghost.texture = sprite.sprite_frames.get_frame_texture(
		sprite.animation,
		frame_index
	)
	ghost.flip_h = sprite.flip_h
	ghost.scale = pose_root.scale
	ghost.position = (
		pose_root.position
		+ sprite.position * pose_root.scale
		- direction * distance
	)
	ghost.modulate = Color(0.58, 1.0, 0.72, alpha)
	ghost.visible = true


func _apply_attack_pose() -> void:
	# Ranged firing keeps the slime upright. Impact and projectile sprites are
	# the only attack feedback; the old lean and blue Line2D are disabled.
	attack_slash.visible = false


func _get_action_animation(action: StringName) -> StringName:
	if action == &"dash":
		return _get_directional_dodge_animation()
	return ACTION_ANIMATIONS.get(action, &"")


func _get_directional_dodge_animation() -> StringName:
	var direction := _get_dash_direction()
	if absf(direction.y) > absf(direction.x):
		return &"run_up" if direction.y < 0.0 else &"run_down"
	return &"dodge"


func _get_dash_direction() -> Vector2:
	if not locked_action_direction.is_zero_approx():
		return locked_action_direction
	if not actor.velocity.is_zero_approx():
		return actor.velocity.normalized()
	if actor.has_method("get_facing_direction"):
		return actor.call("get_facing_direction") as Vector2
	return Vector2.RIGHT


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
	if current_action == &"dash" and not locked_action_direction.is_zero_approx():
		if absf(locked_action_direction.x) > 0.05:
			facing_sign = (
				1.0 if locked_action_direction.x < 0.0 else -1.0
			)
	elif absf(actor.velocity.x) > 1.0:
		facing_sign = 1.0 if actor.velocity.x < 0.0 else -1.0
	elif current_action in [&"attack", &"dash", &"jump", &"slide"]:
		var direction := Vector2.ZERO
		if actor.has_method("get_facing_direction"):
			direction = actor.call("get_facing_direction") as Vector2
		if absf(direction.x) > 0.05:
			facing_sign = 1.0 if direction.x < 0.0 else -1.0
	# Only the side animation is mirrored. Up/down have authored frames.
	if sprite.animation == &"run_up" or sprite.animation == &"run_down":
		sprite.flip_h = false
	else:
		sprite.flip_h = facing_sign < 0.0
	_align_sprite_to_ground()


func _get_directional_run_animation() -> StringName:
	var direction := actor.velocity
	if absf(direction.x) >= absf(direction.y):
		return &"run_side"
	return &"run_up" if direction.y < 0.0 else &"run_down"


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
	# Ranged slime attacks keep the authored locomotion pose. Projectile
	# feedback carries the attack, so there is no lean or blue slash overlay.
	pass


func _on_dash_started(direction: Vector2) -> void:
	play_action(&"dash", 0.34, direction)


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
