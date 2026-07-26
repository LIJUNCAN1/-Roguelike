class_name ActorVisualData
extends Resource

@export_group("Atlas")
@export var atlas_texture: Texture2D
@export var frame_regions: Array[Rect2] = []
@export var visual_scale: Vector2 = Vector2.ONE
@export var visual_offset: Vector2 = Vector2.ZERO

@export_group("Animation Frames")
@export var idle_frames: PackedInt32Array = PackedInt32Array([0])
@export var move_frames: PackedInt32Array = PackedInt32Array([0])
@export var attack_frames: PackedInt32Array = PackedInt32Array([0])
@export var hurt_frames: PackedInt32Array = PackedInt32Array([0])
@export var death_frames: PackedInt32Array = PackedInt32Array([0])
@export var evolution_frames: PackedInt32Array = PackedInt32Array([0])
@export_range(1.0, 30.0, 0.5)
var frames_per_second: float = 6.0


func get_frames(state: StringName) -> PackedInt32Array:
	match state:
		&"move":
			return move_frames
		&"attack":
			return attack_frames
		&"hurt":
			return hurt_frames
		&"death":
			return death_frames
		&"evolution":
			return evolution_frames
	return idle_frames
