class_name EnemyAnimationPresenter
extends Node2D

@export var animation_set: EnemyAnimationSet
@export_node_path("Node2D") var fallback_visual_path: NodePath

@onready var actor := get_parent() as CharacterBody2D
@onready var fallback_visual := get_node_or_null(fallback_visual_path) as Node2D

var sprite := AnimatedSprite2D.new()
var locked_state: bool = false
var awakened_visual: bool = false


func _ready() -> void:
	sprite.name = "AnimatedEnemySprite"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = true
	add_child(sprite)
	var health := actor.get_node_or_null("HealthComponent") as HealthComponent
	if health != null:
		health.damaged.connect(_on_damaged)
		health.died.connect(_on_died)
	if actor.has_signal("attack_performed"):
		actor.connect("attack_performed", _on_attack)
	if actor.has_signal("projectile_fired"):
		actor.connect("projectile_fired", _on_attack)
	if actor.has_signal("attack_telegraphed"):
		actor.connect("attack_telegraphed", _on_attack)
	configure(animation_set)


func configure(data: EnemyAnimationSet) -> void:
	animation_set = data
	var valid := animation_set != null and animation_set.idle_texture != null
	sprite.visible = valid
	if fallback_visual != null:
		fallback_visual.visible = not valid
	if not valid:
		return
	sprite.sprite_frames = SpriteFrames.new()
	sprite.sprite_frames.remove_animation(&"default")
	_add_animation(&"idle", animation_set.idle_texture, animation_set.idle_frames, animation_set.idle_fps, true)
	_add_animation(&"move", animation_set.move_texture, animation_set.move_frames, animation_set.move_fps, true)
	_add_animation(&"attack", animation_set.attack_texture, animation_set.attack_frames, animation_set.attack_fps, false)
	_add_animation(&"hurt", animation_set.hurt_texture, animation_set.hurt_frames, animation_set.hurt_fps, false)
	_add_animation(&"death", animation_set.death_texture, animation_set.death_frames, animation_set.death_fps, false)
	_add_animation(&"awaken", animation_set.awaken_texture, animation_set.awaken_frames, animation_set.awaken_fps, false)
	_add_animation(&"transform", animation_set.transform_texture, animation_set.transform_frames, animation_set.transform_fps, false)
	_add_animation(&"idle_awake", animation_set.awakened_idle_texture, animation_set.awakened_idle_frames, animation_set.awakened_idle_fps, true)
	sprite.scale = animation_set.visual_scale
	sprite.position = animation_set.visual_offset
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play(&"idle")


func _process(_delta: float) -> void:
	if not sprite.visible or locked_state:
		return
	var facing := actor.velocity
	if actor.has_method("get_facing_direction"):
		facing = actor.call("get_facing_direction") as Vector2
	if not facing.is_zero_approx():
		var points_left := facing.x < 0.0
		sprite.flip_h = points_left if animation_set.faces_right else not points_left
	var next := &"move" if actor.velocity.length_squared() > 4.0 else (&"idle_awake" if awakened_visual and sprite.sprite_frames.has_animation(&"idle_awake") else &"idle")
	if sprite.animation != next:
		sprite.play(next)


func play_awaken() -> void:
	_play_one_shot(&"awaken")


func get_death_duration() -> float:
	if animation_set == null:
		return 0.0
	return animation_set.get_death_duration()


func _add_animation(name: StringName, texture: Texture2D, frame_count: int, fps: float, loop: bool) -> void:
	if texture == null:
		return
	sprite.sprite_frames.add_animation(name)
	sprite.sprite_frames.set_animation_speed(name, fps)
	sprite.sprite_frames.set_animation_loop(name, loop)
	var count := maxi(frame_count, 1)
	var frame_width := float(texture.get_width()) / float(count)
	for index in count:
		var frame := AtlasTexture.new()
		frame.atlas = texture
		frame.region = Rect2(frame_width * index, 0.0, frame_width, texture.get_height())
		sprite.sprite_frames.add_frame(name, frame)


func _play_one_shot(name: StringName) -> void:
	if not sprite.sprite_frames.has_animation(name):
		return
	locked_state = true
	sprite.play(name)


func _on_attack(_arg1: Variant = null, _arg2: Variant = null) -> void:
	_play_one_shot(&"attack")


func _on_damaged(_amount: float, _health: float, _source: Node) -> void:
	_play_one_shot(&"hurt")


func _on_died(_source: Node) -> void:
	locked_state = true
	if sprite.sprite_frames.has_animation(&"death"):
		sprite.play(&"death")


func _on_animation_finished() -> void:
	if sprite.animation == &"death":
		return
	if sprite.animation == &"awaken" and sprite.sprite_frames.has_animation(&"transform"):
		sprite.play(&"transform")
		return
	if sprite.animation == &"transform" or sprite.animation == &"awaken":
		awakened_visual = true
	locked_state = false
	sprite.play(&"idle_awake" if awakened_visual and sprite.sprite_frames.has_animation(&"idle_awake") else &"idle")
