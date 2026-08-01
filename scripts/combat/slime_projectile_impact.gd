class_name SlimeProjectileImpact
extends Node2D

const IMPACT_TEXTURE := preload(
	"res://assets/sprites/combat/slime_shot/impact.png"
)
const FRAME_SIZE := Vector2i(64, 64)
const FRAME_COUNT := 5

@export var impact_fps := 14.0
@export var visual_scale := Vector2(0.68, 0.68)

var sprite := AnimatedSprite2D.new()


func _ready() -> void:
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = visual_scale
	add_child(sprite)
	_build_frames()
	sprite.animation_finished.connect(queue_free)


func play_hit() -> void:
	_play_from_frame(0)


func play_miss() -> void:
	# The last three authored frames are the flattened ground splash.
	_play_from_frame(2)


func _build_frames() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for animation_name in [&"hit", &"miss"]:
		frames.add_animation(animation_name)
		frames.set_animation_speed(animation_name, impact_fps)
		frames.set_animation_loop(animation_name, false)
	var hit_indices := range(FRAME_COUNT)
	var miss_indices := range(2, FRAME_COUNT)
	for frame_index in hit_indices:
		frames.add_frame(&"hit", _atlas_frame(frame_index))
	for frame_index in miss_indices:
		frames.add_frame(&"miss", _atlas_frame(frame_index))
	sprite.sprite_frames = frames


func _atlas_frame(frame_index: int) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = IMPACT_TEXTURE
	frame.region = Rect2(
		Vector2(frame_index * FRAME_SIZE.x, 0),
		Vector2(FRAME_SIZE)
	)
	return frame


func _play_from_frame(frame_index: int) -> void:
	var animation := &"hit" if frame_index == 0 else &"miss"
	sprite.play(animation)
