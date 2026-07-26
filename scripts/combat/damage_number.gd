class_name DamageNumber
extends Node2D

@onready var label: Label = $Label

var damage_amount: float = 0.0
var text_color: Color = Color.WHITE


func setup(amount: float, color: Color) -> void:
	damage_amount = amount
	text_color = color


func play(rise_distance: float, duration: float) -> void:
	label.text = str(roundi(damage_amount))
	label.modulate = text_color
	scale = Vector2(0.75, 0.75)

	var transparent_color := text_color
	transparent_color.a = 0.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		self,
		"position",
		position + Vector2.UP * rise_distance,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, duration * 0.35)
	tween.tween_property(label, "modulate", transparent_color, duration)
	tween.chain().tween_callback(queue_free)
