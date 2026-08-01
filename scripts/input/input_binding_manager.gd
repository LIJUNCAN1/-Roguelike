class_name InputBindingManager
extends Node

signal bindings_changed(device_type: StringName)
signal active_device_changed(device_type: StringName)

const SETTINGS_PATH := "user://input_bindings.cfg"
const DEVICE_KEYBOARD := &"keyboard"
const DEVICE_GAMEPAD := &"gamepad"

const ACTION_DEFINITIONS := [
	{"action": &"move_up", "label": "上"},
	{ "action": &"move_down", "label": "下" },
	{ "action": &"move_left", "label": "左" },
	{ "action": &"move_right", "label": "右" },
	{ "action": &"jump", "label": "跳跃" },
	{ "action": &"attack_up", "label": "向上发射" },
	{ "action": &"attack_down", "label": "向下发射" },
	{ "action": &"attack_left", "label": "向左发射" },
	{ "action": &"attack_right", "label": "向右发射" },
	{ "action": &"dash", "label": "闪避" },
	{ "action": &"slide", "label": "滑铲" },
	{ "action": &"interact", "label": "交互" },
	{ "action": &"toggle_gene_codex", "label": "图鉴" },
	{ "action": &"pause_game", "label": "菜单" },
]

const KEYBOARD_DEFAULTS := {
	&"move_up": KEY_W,
	&"move_down": KEY_S,
	&"move_left": KEY_A,
	&"move_right": KEY_D,
	&"jump": KEY_Q,
	&"attack_up": KEY_UP,
	&"attack_down": KEY_DOWN,
	&"attack_left": KEY_LEFT,
	&"attack_right": KEY_RIGHT,
	&"dash": KEY_SPACE,
	&"slide": KEY_X,
	&"interact": KEY_E,
	&"toggle_gene_codex": KEY_C,
	&"pause_game": KEY_ESCAPE,
}

const GAMEPAD_DEFAULTS := {
	&"move_up": {"type": "axis", "index": JOY_AXIS_LEFT_Y, "value": -1.0},
	&"move_down": {"type": "axis", "index": JOY_AXIS_LEFT_Y, "value": 1.0},
	&"move_left": {"type": "axis", "index": JOY_AXIS_LEFT_X, "value": -1.0},
	&"move_right": {"type": "axis", "index": JOY_AXIS_LEFT_X, "value": 1.0},
	&"jump": {"type": "button", "index": JOY_BUTTON_A},
	&"attack_up": {"type": "axis", "index": JOY_AXIS_RIGHT_Y, "value": -1.0},
	&"attack_down": {"type": "axis", "index": JOY_AXIS_RIGHT_Y, "value": 1.0},
	&"attack_left": {"type": "axis", "index": JOY_AXIS_RIGHT_X, "value": -1.0},
	&"attack_right": {"type": "axis", "index": JOY_AXIS_RIGHT_X, "value": 1.0},
	&"dash": {"type": "button", "index": JOY_BUTTON_B},
	&"slide": {"type": "button", "index": JOY_BUTTON_RIGHT_SHOULDER},
	&"interact": {"type": "button", "index": JOY_BUTTON_Y},
	&"toggle_gene_codex": {"type": "button", "index": JOY_BUTTON_BACK},
	&"pause_game": {"type": "button", "index": JOY_BUTTON_START},
}

var active_device: StringName = DEVICE_KEYBOARD
var settings_path := SETTINGS_PATH


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_apply_defaults(DEVICE_KEYBOARD)
	_apply_defaults(DEVICE_GAMEPAD)
	_load_bindings()


func _input(event: InputEvent) -> void:
	var next_device := active_device
	if event is InputEventJoypadButton and event.pressed:
		next_device = DEVICE_GAMEPAD
	elif event is InputEventJoypadMotion and absf(event.axis_value) >= 0.55:
		next_device = DEVICE_GAMEPAD
	elif event is InputEventKey and event.pressed:
		next_device = DEVICE_KEYBOARD
	elif event is InputEventMouseButton and event.pressed:
		next_device = DEVICE_KEYBOARD
	if next_device != active_device:
		active_device = next_device
		active_device_changed.emit(active_device)


func get_action_definitions() -> Array:
	return ACTION_DEFINITIONS.duplicate(true)


func get_binding(action: StringName, device_type: StringName) -> InputEvent:
	if not InputMap.has_action(action):
		return null
	for event in InputMap.action_get_events(action):
		if _is_device_event(event, device_type):
			return event
	return null


func get_binding_text(action: StringName, device_type := active_device) -> String:
	return event_to_text(get_binding(action, device_type), device_type)


func set_binding(
	action: StringName,
	device_type: StringName,
	event: InputEvent
) -> String:
	if event == null or not _is_device_event(event, device_type):
		return "不支持这个输入"
	var conflict_label := ""
	for definition in ACTION_DEFINITIONS:
		var other_action := definition["action"] as StringName
		if other_action == action:
			continue
		var other_event := get_binding(other_action, device_type)
		if _events_match(other_event, event):
			_remove_device_events(other_action, device_type)
			conflict_label = String(definition["label"])
	_replace_device_event(action, device_type, event)
	_save_bindings()
	bindings_changed.emit(device_type)
	if conflict_label.is_empty():
		return "已保存"
	return "已保存，并解除“%s”的重复绑定" % conflict_label


func reset_device(device_type: StringName) -> void:
	_apply_defaults(device_type)
	_save_bindings()
	bindings_changed.emit(device_type)


func capture_event(
	event: InputEvent,
	device_type: StringName
) -> InputEvent:
	if device_type == DEVICE_KEYBOARD and event is InputEventKey:
		if not event.pressed or event.echo:
			return null
		var key_event := InputEventKey.new()
		key_event.physical_keycode = (
			event.physical_keycode
			if event.physical_keycode != 0
			else event.keycode
		)
		return key_event
	if device_type == DEVICE_GAMEPAD:
		if event is InputEventJoypadButton and event.pressed:
			var button_event := InputEventJoypadButton.new()
			button_event.device = -1
			button_event.button_index = event.button_index
			return button_event
		if event is InputEventJoypadMotion and absf(event.axis_value) >= 0.75:
			var motion_event := InputEventJoypadMotion.new()
			motion_event.device = -1
			motion_event.axis = event.axis
			motion_event.axis_value = signf(event.axis_value)
			return motion_event
	return null


func event_to_text(event: InputEvent, device_type: StringName) -> String:
	if event == null:
		return "未设置"
	if event is InputEventKey:
		var keycode: int = (
			event.physical_keycode
			if event.physical_keycode != 0
			else event.keycode
		)
		return OS.get_keycode_string(keycode)
	if event is InputEventJoypadButton:
		return _joy_button_text(event.button_index)
	if event is InputEventJoypadMotion:
		return _joy_axis_text(event.axis, event.axis_value)
	return "未设置" if device_type == DEVICE_GAMEPAD else event.as_text()


func _apply_defaults(device_type: StringName) -> void:
	for definition in ACTION_DEFINITIONS:
		var action := definition["action"] as StringName
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.2)
		var event: InputEvent
		if device_type == DEVICE_KEYBOARD:
			var key_event := InputEventKey.new()
			key_event.physical_keycode = int(KEYBOARD_DEFAULTS[action])
			event = key_event
		else:
			event = _gamepad_event_from_data(GAMEPAD_DEFAULTS[action])
		_replace_device_event(action, device_type, event)


func _replace_device_event(
	action: StringName,
	device_type: StringName,
	event: InputEvent
) -> void:
	_remove_device_events(action, device_type)
	InputMap.action_add_event(action, event)


func _remove_device_events(action: StringName, device_type: StringName) -> void:
	if not InputMap.has_action(action):
		return
	for event in InputMap.action_get_events(action):
		if _is_device_event(event, device_type):
			InputMap.action_erase_event(action, event)


func _is_device_event(event: InputEvent, device_type: StringName) -> bool:
	if device_type == DEVICE_KEYBOARD:
		return event is InputEventKey
	return event is InputEventJoypadButton or event is InputEventJoypadMotion


func _events_match(first: InputEvent, second: InputEvent) -> bool:
	if first == null or second == null or first.get_class() != second.get_class():
		return false
	if first is InputEventKey:
		return first.physical_keycode == second.physical_keycode
	if first is InputEventJoypadButton:
		return first.button_index == second.button_index
	if first is InputEventJoypadMotion:
		return (
			first.axis == second.axis
			and signf(first.axis_value) == signf(second.axis_value)
		)
	return false


func _save_bindings() -> void:
	var config := ConfigFile.new()
	for definition in ACTION_DEFINITIONS:
		var action := definition["action"] as StringName
		var keyboard_event := get_binding(action, DEVICE_KEYBOARD)
		var gamepad_event := get_binding(action, DEVICE_GAMEPAD)
		if keyboard_event is InputEventKey:
			config.set_value(
				"keyboard",
				String(action),
				int(keyboard_event.physical_keycode)
			)
		if gamepad_event != null:
			config.set_value(
				"gamepad",
				String(action),
				_event_to_data(gamepad_event)
			)
	config.save(settings_path)


func _load_bindings() -> void:
	var config := ConfigFile.new()
	if config.load(settings_path) != OK:
		return
	for definition in ACTION_DEFINITIONS:
		var action := definition["action"] as StringName
		if config.has_section_key("keyboard", String(action)):
			var key_event := InputEventKey.new()
			key_event.physical_keycode = int(
				config.get_value("keyboard", String(action))
			)
			_replace_device_event(action, DEVICE_KEYBOARD, key_event)
		if config.has_section_key("gamepad", String(action)):
			var data: Dictionary = config.get_value(
				"gamepad",
				String(action)
			) as Dictionary
			var gamepad_event := _gamepad_event_from_data(data)
			if gamepad_event != null:
				_replace_device_event(action, DEVICE_GAMEPAD, gamepad_event)


func _event_to_data(event: InputEvent) -> Dictionary:
	if event is InputEventJoypadButton:
		return {"type": "button", "index": event.button_index}
	if event is InputEventJoypadMotion:
		return {
			"type": "axis",
			"index": event.axis,
			"value": signf(event.axis_value),
		}
	return {}


func _gamepad_event_from_data(data: Dictionary) -> InputEvent:
	if String(data.get("type", "")) == "button":
		var button_event := InputEventJoypadButton.new()
		button_event.device = -1
		button_event.button_index = int(data.get("index", 0))
		return button_event
	if String(data.get("type", "")) == "axis":
		var motion_event := InputEventJoypadMotion.new()
		motion_event.device = -1
		motion_event.axis = int(data.get("index", 0))
		motion_event.axis_value = float(data.get("value", 1.0))
		return motion_event
	return null


func _joy_button_text(button_index: int) -> String:
	var names := {
		JOY_BUTTON_A: "A",
		JOY_BUTTON_B: "B",
		JOY_BUTTON_X: "X",
		JOY_BUTTON_Y: "Y",
		JOY_BUTTON_BACK: "View",
		JOY_BUTTON_START: "Menu",
		JOY_BUTTON_LEFT_SHOULDER: "LB",
		JOY_BUTTON_RIGHT_SHOULDER: "RB",
		JOY_BUTTON_LEFT_STICK: "LS",
		JOY_BUTTON_RIGHT_STICK: "RS",
		JOY_BUTTON_DPAD_UP: "方向键 ↑",
		JOY_BUTTON_DPAD_DOWN: "方向键 ↓",
		JOY_BUTTON_DPAD_LEFT: "方向键 ←",
		JOY_BUTTON_DPAD_RIGHT: "方向键 →",
	}
	return String(names.get(button_index, "按钮 %d" % button_index))


func _joy_axis_text(axis: int, value: float) -> String:
	var direction := "+" if value > 0.0 else "-"
	match axis:
		JOY_AXIS_LEFT_X:
			return "左摇杆 →" if value > 0.0 else "左摇杆 ←"
		JOY_AXIS_LEFT_Y:
			return "左摇杆 ↓" if value > 0.0 else "左摇杆 ↑"
		JOY_AXIS_RIGHT_X:
			return "右摇杆 →" if value > 0.0 else "右摇杆 ←"
		JOY_AXIS_RIGHT_Y:
			return "右摇杆 ↓" if value > 0.0 else "右摇杆 ↑"
		JOY_AXIS_TRIGGER_LEFT:
			return "LT"
		JOY_AXIS_TRIGGER_RIGHT:
			return "RT"
	return "轴 %d %s" % [axis, direction]
