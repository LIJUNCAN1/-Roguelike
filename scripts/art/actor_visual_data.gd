class_name ActorVisualData
extends Resource

@export_group("Atlas")
@export var atlas_texture: Texture2D
@export var frame_regions: Array[Rect2] = []
@export var visual_scale: Vector2 = Vector2.ONE
@export var visual_offset: Vector2 = Vector2.ZERO

@export_group("Directional Overrides")
@export var down_frames: ActorDirectionFramesData
@export var up_frames: ActorDirectionFramesData
@export var side_frames: ActorDirectionFramesData

@export_group("Animation Frames")
@export var idle_frames: PackedInt32Array = PackedInt32Array([0])
@export var move_frames: PackedInt32Array = PackedInt32Array([0])
@export var attack_frames: PackedInt32Array = PackedInt32Array([0])
@export var dash_frames: PackedInt32Array = PackedInt32Array()
@export var hurt_frames: PackedInt32Array = PackedInt32Array([0])
@export var death_frames: PackedInt32Array = PackedInt32Array([0])
@export var evolution_frames: PackedInt32Array = PackedInt32Array([0])
@export_range(1.0, 30.0, 0.5)
var frames_per_second: float = 6.0


func get_frames(
	state: StringName,
	direction: StringName = &"down"
) -> PackedInt32Array:
	var direction_data := _get_direction_data(direction)
	if direction_data != null:
		var directional := direction_data.get_frames(state)
		if not directional.is_empty():
			return directional
	match state:
		&"move":
			return move_frames
		&"attack":
			return attack_frames
		&"dash":
			return dash_frames if not dash_frames.is_empty() else move_frames
		&"hurt":
			return hurt_frames
		&"death":
			return death_frames
		&"evolution":
			return evolution_frames
	return idle_frames


func has_directional_frames() -> bool:
	return (
		down_frames != null
		or up_frames != null
		or side_frames != null
	)


func _get_direction_data(
	direction: StringName
) -> ActorDirectionFramesData:
	match direction:
		&"up":
			return up_frames
		&"side":
			return side_frames
	return down_frames
