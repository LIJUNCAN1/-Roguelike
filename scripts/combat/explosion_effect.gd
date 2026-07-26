class_name ExplosionEffect
extends Node2D

@onready var visuals: Node2D = $Visuals

var effect_color: Color = Color.WHITE


func setup(color: Color) -> void:
	effect_color = color


func play(radius: float, duration: float) -> void:
	visuals.modulate = effect_color
	visuals.scale = Vector2(0.2, 0.2)
	var target_scale := Vector2.ONE * (radius / 16.0)
	var transparent_color := effect_color
	transparent_color.a = 0.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		visuals,
		"scale",
		target_scale,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(visuals, "modulate", transparent_color, duration)
	tween.chain().tween_callback(queue_free)
