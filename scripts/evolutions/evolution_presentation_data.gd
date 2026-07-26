class_name EvolutionPresentationData
extends Resource

@export var accent_color: Color = Color(0.45, 1.0, 0.7, 1.0)
@export_multiline var attack_change_text: String = "攻击器官已重构"
@export_range(0.1, 3.0, 0.05, "or_greater")
var transformation_duration: float = 0.8
@export_range(1.0, 3.0, 0.05, "or_greater")
var pulse_scale: float = 1.35
@export_range(0.0, 5.0, 0.05, "or_greater")
var invulnerability_duration: float = 0.75
@export_range(0.0, 32.0, 0.5, "or_greater")
var shake_strength: float = 8.0
@export_range(8.0, 160.0, 1.0, "or_greater")
var burst_radius: float = 54.0
@export_range(1, 8, 1)
var burst_ring_count: int = 3
