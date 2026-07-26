class_name DeathEffect
extends Node2D

@onready var visuals: Node2D = $Visuals

var effect_color: Color = Color.WHITE


func setup(color: Color) -> void:
	effect_color = color


func play(duration: float) -> void:
	visuals.modulate = effect_color
	visuals.scale = Vector2(0.45, 0.45)

	var transparent_color := effect_color
	transparent_color.a = 0.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		visuals,
		"scale",
		Vector2(1.8, 1.8),
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(visuals, "rotation", 0.7, duration)
	tween.tween_property(visuals, "modulate", transparent_color, duration)
	tween.chain().tween_callback(queue_free)
