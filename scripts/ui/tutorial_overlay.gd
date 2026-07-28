class_name TutorialOverlay
extends CanvasLayer

const SETTINGS_PATH := "user://display_settings.cfg"
const DEFAULT_SHOW_CONTROL_HINTS := true

@onready var panel: Control = $ControlHints


func _ready() -> void:
	var config := ConfigFile.new()
	var show_hints := DEFAULT_SHOW_CONTROL_HINTS
	if config.load(SETTINGS_PATH) == OK:
		show_hints = bool(
			config.get_value(
				"interface",
				"show_control_hints",
				DEFAULT_SHOW_CONTROL_HINTS
			)
		)
	panel.visible = show_hints


func dismiss() -> void:
	panel.visible = false


func is_tutorial_visible() -> bool:
	return panel.visible
