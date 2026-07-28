class_name PauseMenu
extends CanvasLayer

signal pause_changed(is_paused: bool)

@export_file("*.tscn") var title_scene_path: String = (
	"res://scenes/hub/hub_world.tscn"
)

@onready var dimmer: Control = $Dimmer
@onready var pause_panel: Control = $Dimmer/Panel
@onready var continue_button: Button = (
	$Dimmer/Panel/Margin/Content/Actions/ContinueButton
)
@onready var settings_button: Button = (
	$Dimmer/Panel/Margin/Content/Actions/SettingsButton
)
@onready var title_button: Button = (
	$Dimmer/Panel/Margin/Content/Actions/TitleButton
)
@onready var settings_panel: Control = $Dimmer/SettingsPanel
@onready var resolution_option: OptionButton = (
	$Dimmer/SettingsPanel/Margin/Content/ResolutionRow/Option
)
@onready var display_mode_option: OptionButton = (
	$Dimmer/SettingsPanel/Margin/Content/WindowModeRow/Option
)
@onready var music_slider: HSlider = (
	$Dimmer/SettingsPanel/Margin/Content/MusicVolumeRow/Slider
)
@onready var music_value_label: Label = (
	$Dimmer/SettingsPanel/Margin/Content/MusicVolumeRow/Value
)
@onready var sfx_slider: HSlider = (
	$Dimmer/SettingsPanel/Margin/Content/SfxVolumeRow/Slider
)
@onready var sfx_value_label: Label = (
	$Dimmer/SettingsPanel/Margin/Content/SfxVolumeRow/Value
)
@onready var control_hints_toggle: CheckButton = (
	$Dimmer/SettingsPanel/Margin/Content/ControlHintsRow/Toggle
)
@onready var settings_status: Label = (
	$Dimmer/SettingsPanel/Margin/Content/Status
)
@onready var settings_apply_button: Button = (
	$Dimmer/SettingsPanel/Margin/Content/Actions/ApplyButton
)
@onready var settings_back_button: Button = (
	$Dimmer/SettingsPanel/Margin/Content/Actions/BackButton
)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	dimmer.visible = false
	settings_panel.visible = false
	continue_button.pressed.connect(resume_game)
	settings_button.pressed.connect(open_settings)
	title_button.pressed.connect(return_to_title)
	settings_apply_button.pressed.connect(apply_settings)
	settings_back_button.pressed.connect(close_settings)
	display_mode_option.item_selected.connect(
		on_display_mode_selected
	)
	music_slider.value_changed.connect(on_audio_volume_changed)
	sfx_slider.value_changed.connect(on_audio_volume_changed)
	setup_settings()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause_game"):
		return
	if get_tree().paused and not dimmer.visible:
		return
	if settings_panel.visible:
		close_settings()
		get_viewport().set_input_as_handled()
		return
	if dimmer.visible:
		resume_game()
	else:
		pause_game()
	get_viewport().set_input_as_handled()


func pause_game() -> bool:
	var run_flow := get_parent().get_node_or_null(
		"RunFlowController"
	) as RunFlowController
	if run_flow != null and run_flow.has_ended:
		return false
	dimmer.visible = true
	pause_panel.visible = true
	settings_panel.visible = false
	get_tree().paused = true
	continue_button.grab_focus()
	pause_changed.emit(true)
	return true


func resume_game() -> void:
	if not dimmer.visible:
		return
	settings_panel.visible = false
	pause_panel.visible = true
	dimmer.visible = false
	get_tree().paused = false
	pause_changed.emit(false)


func return_to_title() -> void:
	settings_panel.visible = false
	dimmer.visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file(title_scene_path)


func is_pause_visible() -> bool:
	return dimmer.visible


func open_settings() -> void:
	setup_settings()
	settings_status.text = ""
	pause_panel.visible = false
	settings_panel.visible = true
	resolution_option.grab_focus()


func close_settings() -> void:
	settings_panel.visible = false
	pause_panel.visible = true
	settings_button.grab_focus()


func setup_settings() -> void:
	DisplaySettingsStore.load_into(
		resolution_option,
		display_mode_option,
		music_slider,
		sfx_slider,
		control_hints_toggle
	)
	update_audio_value_labels()


func on_display_mode_selected(mode_index: int) -> void:
	DisplaySettingsStore.update_resolution_availability(
		resolution_option,
		mode_index
	)


func on_audio_volume_changed(_value: float) -> void:
	DisplaySettingsStore.apply_audio(
		music_slider.value,
		sfx_slider.value
	)
	update_audio_value_labels()


func update_audio_value_labels() -> void:
	music_value_label.text = "%d%%" % roundi(music_slider.value)
	sfx_value_label.text = "%d%%" % roundi(sfx_slider.value)


func apply_settings() -> void:
	DisplaySettingsStore.apply_and_save(
		resolution_option,
		display_mode_option,
		music_slider,
		sfx_slider,
		control_hints_toggle
	)
	settings_status.text = "设置已应用并保存"
	close_settings()
