class_name InteractionPrompt
extends Control

@onready var prompt_label: Label = $Panel/Margin/Content/Prompt
@onready var key_icon: TextureRect = $Panel/Margin/Content/KeyIcon

var keyboard_icon_atlas: Texture2D = preload("res://assets/ui/kb_dark_all.png")

var _fade_tween: Tween
var _current_interactable: Interactable


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var bindings := get_node_or_null(
		"/root/InputBindings"
	) as InputBindingManager
	if bindings != null:
		bindings.active_device_changed.connect(_on_active_device_changed)
		bindings.bindings_changed.connect(_on_bindings_changed)


func show_interactable(interactable: Interactable) -> void:
	if interactable == null:
		hide_prompt()
		return
	_current_interactable = interactable
	_refresh_prompt()
	visible = true
	_fade_to(1.0)


func hide_prompt() -> void:
	if not visible:
		return
	_fade_to(0.0, true)
	_current_interactable = null


func _on_active_device_changed(_device_type: StringName) -> void:
	_refresh_prompt()


func _on_bindings_changed(_device_type: StringName) -> void:
	_refresh_prompt()


func _refresh_prompt() -> void:
	if _current_interactable != null:
		var bindings := get_node_or_null("/root/InputBindings") as InputBindingManager
		var use_keyboard := bindings == null or bindings.active_device == InputBindingManager.DEVICE_KEYBOARD
		key_icon.visible = use_keyboard
		if use_keyboard and bindings != null:
			key_icon.texture = KeyIconAtlas.texture_for_event(
				keyboard_icon_atlas,
				bindings.get_binding(&"interact", InputBindingManager.DEVICE_KEYBOARD)
			)
		prompt_label.text = _current_interactable.display_name + "\n交互"


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
