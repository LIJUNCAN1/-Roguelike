class_name EnemyAnimationSet
extends Resource

@export_group("Layout")
@export var visual_scale: Vector2 = Vector2.ONE
@export var visual_offset: Vector2 = Vector2.ZERO
@export var faces_right: bool = true

@export_group("Idle")
@export var idle_texture: Texture2D
@export_range(1, 64, 1) var idle_frames: int = 1
@export_range(1.0, 30.0, 0.5) var idle_fps: float = 8.0

@export_group("Move")
@export var move_texture: Texture2D
@export_range(1, 64, 1) var move_frames: int = 1
@export_range(1.0, 30.0, 0.5) var move_fps: float = 10.0

@export_group("Attack")
@export var attack_texture: Texture2D
@export_range(1, 64, 1) var attack_frames: int = 1
@export_range(1.0, 30.0, 0.5) var attack_fps: float = 12.0

@export_group("Hurt")
@export var hurt_texture: Texture2D
@export_range(1, 64, 1) var hurt_frames: int = 1
@export_range(1.0, 30.0, 0.5) var hurt_fps: float = 12.0

@export_group("Death")
@export var death_texture: Texture2D
@export_range(1, 64, 1) var death_frames: int = 1
@export_range(1.0, 30.0, 0.5) var death_fps: float = 10.0

@export_group("Awaken (optional)")
@export var awaken_texture: Texture2D
@export_range(1, 64, 1) var awaken_frames: int = 1
@export_range(1.0, 30.0, 0.5) var awaken_fps: float = 10.0
@export var transform_texture: Texture2D
@export_range(1, 64, 1) var transform_frames: int = 1
@export_range(1.0, 30.0, 0.5) var transform_fps: float = 10.0
@export var awakened_idle_texture: Texture2D
@export_range(1, 64, 1) var awakened_idle_frames: int = 1
@export_range(1.0, 30.0, 0.5) var awakened_idle_fps: float = 8.0


func get_death_duration() -> float:
	return float(death_frames) / maxf(death_fps, 1.0)
