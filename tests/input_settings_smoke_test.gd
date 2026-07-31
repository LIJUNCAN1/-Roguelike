extends SceneTree

const TEST_SETTINGS_PATH := "user://input_bindings_smoke_test.cfg"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var bindings := root.get_node("InputBindings") as InputBindingManager
	bindings.settings_path = TEST_SETTINGS_PATH
	bindings.reset_device(InputBindingManager.DEVICE_KEYBOARD)
	bindings.reset_device(InputBindingManager.DEVICE_GAMEPAD)

	var move_up_key := bindings.get_binding(
		&"move_up",
		InputBindingManager.DEVICE_KEYBOARD
	) as InputEventKey
	var attack_button := bindings.get_binding(
		&"attack",
		InputBindingManager.DEVICE_GAMEPAD
	) as InputEventJoypadButton
	var move_left_axis := bindings.get_binding(
		&"move_left",
		InputBindingManager.DEVICE_GAMEPAD
	) as InputEventJoypadMotion
	if (
		move_up_key == null
		or move_up_key.physical_keycode != KEY_W
		or attack_button == null
		or attack_button.button_index != JOY_BUTTON_X
		or move_left_axis == null
		or move_left_axis.axis != JOY_AXIS_LEFT_X
		or move_left_axis.axis_value >= 0.0
	):
		push_error("Default keyboard or Xbox bindings are invalid.")
		quit(1)
		return
	var simulated_axis := InputEventJoypadMotion.new()
	simulated_axis.device = 0
	simulated_axis.axis = JOY_AXIS_LEFT_X
	simulated_axis.axis_value = 1.0
	bindings._input(simulated_axis)
	if (
		not simulated_axis.is_action(&"move_right")
		or bindings.active_device != InputBindingManager.DEVICE_GAMEPAD
	):
		push_error(
			"Gamepad axis did not match InputMap or switch input device."
		)
		quit(1)
		return

	var replacement := InputEventKey.new()
	replacement.physical_keycode = KEY_T
	bindings.set_binding(
		&"move_down",
		InputBindingManager.DEVICE_KEYBOARD,
		replacement
	)
	if (
		bindings.get_binding(&"move_up", InputBindingManager.DEVICE_KEYBOARD) == null
		or bindings.get_binding_text(
			&"move_down",
			InputBindingManager.DEVICE_KEYBOARD
		) != "T"
	):
		push_error("Keyboard rebinding failed.")
		quit(1)
		return
	bindings.set_binding(
		&"move_up",
		InputBindingManager.DEVICE_KEYBOARD,
		replacement
	)
	if bindings.get_binding(
		&"move_down",
		InputBindingManager.DEVICE_KEYBOARD
	) != null:
		push_error("Duplicate keyboard binding was not removed.")
		quit(1)
		return

	var panel := (
		load("res://scenes/ui/settings_panel.tscn") as PackedScene
	).instantiate() as InputSettingsPanel
	root.add_child(panel)
	await process_frame
	panel.show_input_page(InputBindingManager.DEVICE_KEYBOARD)
	if (
		not panel.input_page.visible
		or not panel.device_tabs.visible
		or not panel.control_tab.button_pressed
		or not panel.keyboard_tab.button_pressed
		or panel.display_controls[0].visible
		or panel.binding_buttons.size()
		!= bindings.get_action_definitions().size()
		or panel.binding_buttons[&"move_up"].icon == null
		or not panel.binding_buttons[&"move_up"].text.is_empty()
	):
		push_error("Keyboard/mouse second-level settings page was not constructed.")
		quit(1)
		return
	panel.show_input_page(InputBindingManager.DEVICE_GAMEPAD)
	if (
		panel.input_subtitle.text != "Xbox 手柄设置"
		or panel.binding_buttons[&"attack"].text != "X"
		or panel.binding_buttons[&"interact"].text != "Y"
	):
		push_error("Gamepad settings page was not configured.")
		quit(1)
		return

	bindings.reset_device(InputBindingManager.DEVICE_KEYBOARD)
	bindings.reset_device(InputBindingManager.DEVICE_GAMEPAD)
	if FileAccess.file_exists(TEST_SETTINGS_PATH):
		DirAccess.remove_absolute(
			ProjectSettings.globalize_path(TEST_SETTINGS_PATH)
		)
	print("Input settings smoke test passed.")
	quit()
