class_name LevelUpVfx
extends Node2D

const FRAME_COUNT := 16
const FRAME_SIZE := Vector2i(48, 48)

@export_node_path("Node") var progression_path: NodePath
@onready var progression: RunProgression = get_node(
	progression_path
) as RunProgression
@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	_build_frames()
	sprite.visible = false
	progression.level_changed.connect(_on_level_changed)


func _build_frames() -> void:
	var texture := preload(
		"res://assets/effects/level_up/holy_vfx_02.png"
	)
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"level_up")
	frames.set_animation_loop(&"level_up", false)
	frames.set_animation_speed(&"level_up", 24.0)
	for index in FRAME_COUNT:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(
			index * FRAME_SIZE.x,
			0,
			FRAME_SIZE.x,
			FRAME_SIZE.y
		)
		frames.add_frame(&"level_up", atlas)
	sprite.sprite_frames = frames
	sprite.animation_finished.connect(_on_animation_finished)


func _on_level_changed(_level: int) -> void:
	sprite.visible = true
	sprite.play(&"level_up")


func _on_animation_finished() -> void:
	sprite.visible = false
