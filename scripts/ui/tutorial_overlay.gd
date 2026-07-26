class_name TutorialOverlay
extends CanvasLayer

@onready var panel: Control = $Panel


func _ready() -> void:
	panel.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if not panel.visible:
		return
	if (
		event.is_action_pressed("move_up")
		or event.is_action_pressed("move_down")
		or event.is_action_pressed("move_left")
		or event.is_action_pressed("move_right")
		or event.is_action_pressed("attack")
		or event.is_action_pressed("ui_accept")
	):
		dismiss()


func dismiss() -> void:
	panel.visible = false


func is_tutorial_visible() -> bool:
	return panel.visible
