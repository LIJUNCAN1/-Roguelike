class_name MusicTrackData
extends Resource

@export var id: StringName
@export var stream: AudioStream
@export_range(-60.0, 12.0, 0.5)
var volume_db: float = -16.0
@export var fallback_notes: PackedFloat32Array = PackedFloat32Array([
	110.0,
	138.59,
	164.81,
	138.59,
])
@export_range(40.0, 240.0, 1.0)
var fallback_tempo: float = 92.0
