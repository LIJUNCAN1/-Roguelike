class_name InteractionPrompt
extends Control

@onready var prompt_label: Label = $Panel/Margin/Prompt

var _fade_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func show_interactable(interactable: Interactable) -> void:
	if interactable == null:
		hide_prompt()
		return
	prompt_label.text = interactable.get_prompt_text()
	visible = true
	_fade_to(1.0)


func hide_prompt() -> void:
	if not visible:
		return
	_fade_to(0.0, true)


func _fade_to(target_alpha: float, hide_after := false) -> void:
	if _fade_tween != null:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(
		self,
		"modulate:a",
		target_alpha,
		0.12
	)
	if hide_after:
		_fade_tween.tween_callback(
			func() -> void: visible = false
		)
