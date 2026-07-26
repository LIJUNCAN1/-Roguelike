class_name EvolutionBurstEffect
extends Node2D

var presentation_data: EvolutionPresentationData
var radius: float = 4.0:
	set(value):
		radius = value
		queue_redraw()


func configure(data: EvolutionPresentationData) -> void:
	presentation_data = data
	if presentation_data == null:
		queue_free()
		return
	radius = 4.0
	modulate.a = 1.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		self,
		"radius",
		presentation_data.burst_radius,
		presentation_data.transformation_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		presentation_data.transformation_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)


func _draw() -> void:
	if presentation_data == null:
		return
	for ring_index in presentation_data.burst_ring_count:
		var spacing := presentation_data.burst_radius / (
			presentation_data.burst_ring_count * 2.0
		)
		var ring_radius := maxf(radius - ring_index * spacing, 2.0)
		var color := presentation_data.accent_color
		color.a = 0.9 - float(ring_index) * 0.15
		draw_arc(
			Vector2.ZERO,
			ring_radius,
			0.0,
			TAU,
			48,
			color,
			2.0
		)
