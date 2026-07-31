class_name InputSettingsPanel
extends TechSettingsPanel

@onready var title_label: Label = $Margin/Content/Title
@onready var display_tab: Button = $Margin/Content/PageTabs/DisplayTab
@onready var control_tab: Button = $Margin/Content/PageTabs/ControlTab
@onready var device_tabs: HBoxContainer = $Margin/Content/DeviceTabs
@onready var keyboard_tab: Button = (
	$Margin/Content/DeviceTabs/KeyboardMouseTab
)
@onready var gamepad_tab: Button = $Margin/Content/DeviceTabs/GamepadTab
@onready var input_page: PanelContainer = $Margin/Content/InputPage
@onready var input_subtitle: Label = $Margin/Content/InputPage/Inner/Subtitle
@onready var device_status: Label = $Margin/Content/InputPage/Inner/DeviceStatus
@onready var binding_grid: GridContainer = (
	$Margin/Content/InputPage/Inner/BindingGrid
)
@onready var label_template: Label = (
	$Margin/Content/InputPage/Inner/BindingGrid/LabelTemplate
)
@onready var button_template: Button = (
	$Margin/Content/InputPage/Inner/BindingGrid/ButtonTemplate
)
@onready var capture_hint: Label = (
	$Margin/Content/InputPage/Inner/CaptureHint
)
@onready var reset_button: Button = (
	$Margin/Content/InputPage/Inner/ResetRow/ResetButton
)
@onready var input_bindings: InputBindingManager = get_node(
	"/root/InputBindings"
) as InputBindingManager
@onready var keyboard_icon_atlas: Texture2D = preload(
	"res://assets/ui/kb_dark_all.png"
)
@onready var display_controls: Array[Control] = [
	$Margin/Content/ResolutionRow,
	$Margin/Content/WindowModeRow,
	$Margin/Content/MusicVolumeRow,
	$Margin/Content/SfxVolumeRow,
	$Margin/Content/ControlHintsRow,
	$Margin/Content/Hint,
]

var current_device: StringName = &"display"
var capture_action: StringName = &""
var capture_armed := false
var binding_buttons: Dictionary[StringName, Button] = {}


func _ready() -> void:
	super._ready()
	process_mode = Node.PROCESS_MODE_ALWAYS
	display_tab.pressed.connect(show_display_page)
	control_tab.pressed.connect(show_control_page)
	keyboard_tab.pressed.connect(
		show_input_page.bind(InputBindingManager.DEVICE_KEYBOARD)
	)
	gamepad_tab.pressed.connect(
		show_input_page.bind(InputBindingManager.DEVICE_GAMEPAD)
	)
	reset_button.pressed.connect(_reset_current_device)
	visibility_changed.connect(_on_visibility_changed)
	input_bindings.bindings_changed.connect(_on_bindings_changed)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_build_binding_grid()
	show_display_page()


func _unhandled_input(event: InputEvent) -> void:
	if capture_action.is_empty() or not capture_armed or not visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_cancel_capture("已取消重新绑定")
		get_viewport().set_input_as_handled()
		return
	var captured := input_bindings.capture_event(event, current_device)
	if captured == null:
		return
	var result := input_bindings.set_binding(
		capture_action,
		current_device,
		captured
	)
	capture_action = &""
	capture_armed = false
	capture_hint.text = result
	_refresh_binding_buttons()
	get_viewport().set_input_as_handled()


func show_display_page() -> void:
	_cancel_capture()
	current_device = &"display"
	title_label.text = "设置"
	display_tab.button_pressed = true
	device_tabs.visible = false
	input_page.visible = false
	for control in display_controls:
		control.visible = true


func show_control_page() -> void:
	var device := current_device
	if device == &"display":
		device = InputBindingManager.DEVICE_KEYBOARD
	show_input_page(device)


func show_input_page(device_type: StringName) -> void:
	_cancel_capture()
	current_device = device_type
	var is_keyboard := device_type == InputBindingManager.DEVICE_KEYBOARD
	title_label.text = "键盘鼠标" if is_keyboard else "手柄"
	input_subtitle.text = "键盘设置" if is_keyboard else "Xbox 手柄设置"
	control_tab.button_pressed = true
	keyboard_tab.button_pressed = is_keyboard
	gamepad_tab.button_pressed = not is_keyboard
	for control in display_controls:
		control.visible = false
	device_tabs.visible = true
	input_page.visible = true
	_update_device_status()
	_refresh_binding_buttons()
	var first_button := _first_binding_button()
	if first_button != null:
		first_button.grab_focus()


func is_capturing_input() -> bool:
	return not capture_action.is_empty()


func _build_binding_grid() -> void:
	var definitions: Array = input_bindings.get_action_definitions()
	var split_index := ceili(float(definitions.size()) / 2.0)
	for row in range(split_index):
		for column in range(2):
			var definition_index := row + column * split_index
			if definition_index >= definitions.size():
				_add_binding_spacer()
				continue
			var definition: Dictionary = definitions[definition_index]
			var action := StringName(definition["action"])
			var action_label := label_template.duplicate() as Label
			action_label.name = "%sLabel" % String(action).to_pascal_case()
			action_label.text = String(definition["label"])
			action_label.visible = true
			binding_grid.add_child(action_label)
			var binding_button := button_template.duplicate() as Button
			binding_button.name = "%sBinding" % String(action).to_pascal_case()
			binding_button.visible = true
			binding_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			binding_button.expand_icon = true
			binding_button.add_theme_constant_override(
				"icon_max_width",
				32
			)
			binding_button.pressed.connect(_begin_capture.bind(action))
			binding_grid.add_child(binding_button)
			binding_buttons[action] = binding_button


func _add_binding_spacer() -> void:
	var label_spacer := Control.new()
	label_spacer.custom_minimum_size = label_template.custom_minimum_size
	label_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	binding_grid.add_child(label_spacer)
	var button_spacer := Control.new()
	button_spacer.custom_minimum_size = button_template.custom_minimum_size
	button_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	binding_grid.add_child(button_spacer)


func _begin_capture(action: StringName) -> void:
	capture_action = action
	capture_armed = false
	var button := binding_buttons.get(action) as Button
	if button != null:
		button.text = "等待输入…"
	capture_hint.text = (
		"请按下新按键，Esc 取消"
		if current_device == InputBindingManager.DEVICE_KEYBOARD
		else "请按下手柄按钮或推动摇杆，Esc 取消"
	)
	call_deferred("_arm_capture")


func _arm_capture() -> void:
	capture_armed = not capture_action.is_empty()


func _cancel_capture(message := "") -> void:
	if not capture_action.is_empty():
		capture_action = &""
		capture_armed = false
		_refresh_binding_buttons()
	if not message.is_empty():
		capture_hint.text = message


func _refresh_binding_buttons() -> void:
	if current_device == &"display":
		return
	for action in binding_buttons:
		var button := binding_buttons[action]
		button.icon = null
		if current_device == InputBindingManager.DEVICE_KEYBOARD:
			button.icon = KeyIconAtlas.texture_for_event(
				keyboard_icon_atlas,
				input_bindings.get_binding(action, current_device)
			)
			button.text = "" if button.icon != null else "未设置"
		else:
			button.text = input_bindings.get_binding_text(
				action,
				current_device
			)


func _reset_current_device() -> void:
	if current_device == &"display":
		return
	input_bindings.reset_device(current_device)
	capture_hint.text = "已恢复默认键位并保存"
	_refresh_binding_buttons()


func _update_device_status() -> void:
	if current_device == InputBindingManager.DEVICE_KEYBOARD:
		device_status.text = "键盘与鼠标"
		return
	var joypads := Input.get_connected_joypads()
	device_status.text = (
		"未检测到手柄，可预先设置"
		if joypads.is_empty()
		else "已连接：%s" % Input.get_joy_name(joypads[0])
	)


func _first_binding_button() -> Button:
	var definitions: Array = input_bindings.get_action_definitions()
	if definitions.is_empty():
		return null
	var first_action := StringName((definitions[0] as Dictionary)["action"])
	return binding_buttons.get(first_action) as Button


func _on_bindings_changed(device_type: StringName) -> void:
	if device_type == current_device:
		_refresh_binding_buttons()


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	if current_device == InputBindingManager.DEVICE_GAMEPAD:
		_update_device_status()


func _on_visibility_changed() -> void:
	if visible:
		_update_device_status()
		_refresh_binding_buttons()
	else:
		_cancel_capture()
