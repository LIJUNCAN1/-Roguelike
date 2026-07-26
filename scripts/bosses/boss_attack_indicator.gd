class_name BossAttackIndicator
extends Node2D

@onready var fill: Polygon2D = $Fill
@onready var ring: Line2D = $Ring


func configure(
	radius: float,
	color: Color,
	telegraph_duration: float
) -> void:
	var points := _make_circle(radius)
	fill.polygon = points
	ring.points = points
	ring.closed = true

	var fill_color := color
	fill_color.a = 0.16
	fill.color = fill_color
	ring.default_color = color
	scale = Vector2.ONE * 0.35

	var tween := create_tween()
	tween.tween_property(
		self,
		"scale",
		Vector2.ONE,
		telegraph_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func impact() -> void:
	var impact_color := ring.default_color
	impact_color.a = 0.7
	fill.color = impact_color
	ring.width = 4.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE * 1.15, 0.18)
	tween.tween_property(self, "modulate:a", 0.0, 0.18)
	tween.chain().tween_callback(queue_free)


func _make_circle(radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var segment_count := 32
	for index in segment_count:
		var angle := TAU * float(index) / float(segment_count)
		points.append(Vector2.from_angle(angle) * radius)
	return points
