class_name AudioCueData
extends Resource

enum Waveform {
	SINE,
	SQUARE,
	TRIANGLE,
	NOISE,
}

@export var id: StringName
@export var stream: AudioStream
@export_range(-60.0, 12.0, 0.5)
var volume_db: float = -8.0
@export_range(20.0, 4000.0, 1.0)
var fallback_frequency: float = 440.0
@export_range(0.02, 3.0, 0.01)
var fallback_duration: float = 0.15
@export var fallback_waveform: Waveform = Waveform.SINE
@export_range(0.0, 0.5, 0.01)
var pitch_randomness: float = 0.06
