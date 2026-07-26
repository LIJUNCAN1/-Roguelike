class_name PixelActorPresenter
extends Node2D

@export var visual_data: ActorVisualData
@export_node_path("Node2D") var fallback_visual_path: NodePath

@onready var actor := get_parent() as CharacterBody2D
@onready var fallback_visual := get_node_or_null(
	fallback_visual_path
) as Node2D

var sprite := Sprite2D.new()
var current_state: StringName = &"idle"
var current_direction: StringName = &"down"
var frame_cursor: int = 0
var frame_elapsed: float = 0.0
var one_shot_remaining: float = 0.0


func _ready() -> void:
	sprite.name = "ReplacementSprite"
	sprite.region_enabled = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	var health := actor.get_node_or_null(
		"HealthComponent"
	) as HealthComponent
	if health != null:
		health.damaged.connect(_on_damaged)
		health.died.connect(_on_died)
	if actor.has_signal("attack_performed"):
		actor.connect("attack_performed", _on_attack)
	if actor.has_signal("projectile_fired"):
		actor.connect("projectile_fired", _on_attack)
	if actor.has_signal("attack_fired"):
		actor.connect("attack_fired", _on_attack)
	if actor.has_signal("dash_started"):
		actor.connect("dash_started", _on_dash)
	if actor.has_signal("phase_changed"):
		actor.connect("phase_changed", _on_phase_changed)
	configure(visual_data)


func configure(data: ActorVisualData) -> void:
	visual_data = data
	var has_replacement := (
		visual_data != null
		and visual_data.atlas_texture != null
		and not visual_data.frame_regions.is_empty()
	)
	sprite.visible = has_replacement
	if fallback_visual != null:
		fallback_visual.visible = not has_replacement
	if not has_replacement:
		return
	sprite.texture = visual_data.atlas_texture
	sprite.scale = visual_data.visual_scale
	sprite.position = visual_data.visual_offset
	_set_state(&"idle", true)


func play_evolution() -> void:
	_play_one_shot(&"evolution", 0.75)


func _process(delta: float) -> void:
	if not sprite.visible or visual_data == null:
		return
	_update_direction()
	if one_shot_remaining > 0.0:
		one_shot_remaining -= delta
	else:
		_set_state(
			&"move" if actor.velocity.length_squared() > 4.0 else &"idle"
		)
	frame_elapsed += delta
	var frame_duration := 1.0 / visual_data.frames_per_second
	if frame_elapsed >= frame_duration:
		frame_elapsed = fmod(frame_elapsed, frame_duration)
		frame_cursor += 1
		_apply_frame()


func _set_state(state: StringName, force: bool = false) -> void:
	if not force and current_state == state:
		return
	current_state = state
	frame_cursor = 0
	frame_elapsed = 0.0
	_apply_frame()


func _play_one_shot(state: StringName, duration: float) -> void:
	_set_state(state, true)
	one_shot_remaining = maxf(duration, 0.05)


func _apply_frame() -> void:
	if visual_data == null:
		return
	var frames := visual_data.get_frames(
		current_state,
		current_direction
	)
	if frames.is_empty():
		return
	var region_index := frames[frame_cursor % frames.size()]
	if (
		region_index < 0
		or region_index >= visual_data.frame_regions.size()
	):
		return
	sprite.region_rect = visual_data.frame_regions[region_index]


func _on_attack(_arg1: Variant = null, _arg2: Variant = null) -> void:
	_play_one_shot(&"attack", 0.28)


func _on_dash(_direction: Vector2) -> void:
	_play_one_shot(&"dash", 0.25)


func _on_damaged(
	_amount: float,
	_current_health: float,
	_source: Node
) -> void:
	_play_one_shot(&"hurt", 0.25)


func _on_died(_source: Node) -> void:
	_play_one_shot(&"death", 0.8)


func _on_phase_changed(
	_phase_index: int,
	_phase: BossPhaseData
) -> void:
	play_evolution()


func _update_direction() -> void:
	var direction := actor.velocity
	if actor.has_method("get_facing_direction"):
		direction = actor.call("get_facing_direction") as Vector2
	if direction.is_zero_approx():
		return

	var next_direction: StringName
	if absf(direction.x) > absf(direction.y):
		next_direction = &"side"
		sprite.flip_h = direction.x < 0.0
	elif direction.y < 0.0:
		next_direction = &"up"
		sprite.flip_h = false
	else:
		next_direction = &"down"
		sprite.flip_h = false

	if next_direction == current_direction:
		return
	current_direction = next_direction
	frame_cursor = 0
	frame_elapsed = 0.0
	_apply_frame()
