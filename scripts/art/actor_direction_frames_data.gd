class_name ActorDirectionFramesData
extends Resource

@export var idle_frames: PackedInt32Array = PackedInt32Array()
@export var move_frames: PackedInt32Array = PackedInt32Array()
@export var attack_frames: PackedInt32Array = PackedInt32Array()
@export var dash_frames: PackedInt32Array = PackedInt32Array()
@export var hurt_frames: PackedInt32Array = PackedInt32Array()
@export var death_frames: PackedInt32Array = PackedInt32Array()
@export var evolution_frames: PackedInt32Array = PackedInt32Array()


func get_frames(state: StringName) -> PackedInt32Array:
	match state:
		&"move":
			return move_frames
		&"attack":
			return attack_frames
		&"dash":
			return dash_frames
		&"hurt":
			return hurt_frames
		&"death":
			return death_frames
		&"evolution":
			return evolution_frames
	return idle_frames
