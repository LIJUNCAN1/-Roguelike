class_name EvolutionAuraPresenter
extends Node2D

@export_node_path("Node") var evolution_system_path: NodePath

@onready var evolution_system: EvolutionSystem = get_node(
	evolution_system_path
) as EvolutionSystem

var presentation_data: EvolutionPresentationData
var pulse_time: float = 0.0


func _ready() -> void:
	evolution_system.evolution_changed.connect(_on_evolution_changed)
	call_deferred("_sync_current")


func _process(delta: float) -> void:
	if presentation_data == null:
		return
	pulse_time += delta
	queue_redraw()


func _draw() -> void:
	if presentation_data == null:
		return
	var pulse := (sin(pulse_time * 3.2) + 1.0) * 0.5
	var color := presentation_data.accent_color
	color.a = lerpf(0.18, 0.42, pulse)
	draw_arc(
		Vector2.ZERO,
		11.0 + pulse * 2.0,
		0.0,
		TAU,
		32,
		color,
		1.4
	)
	color.a *= 0.55
	draw_circle(Vector2.ZERO, 9.0 + pulse, color)


func _sync_current() -> void:
	_set_presentation(evolution_system.get_current_evolution())


func _on_evolution_changed(
	_previous: EvolutionData,
	current: EvolutionData
) -> void:
	_set_presentation(current)


func _set_presentation(evolution: EvolutionData) -> void:
	presentation_data = (
		evolution.presentation_data if evolution != null else null
	)
	pulse_time = 0.0
	queue_redraw()
