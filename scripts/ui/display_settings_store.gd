class_name DisplaySettingsStore
extends RefCounted

const SETTINGS_PATH := "user://display_settings.cfg"
const DISPLAY_MODE_WINDOWED := 0
const DISPLAY_MODE_FULLSCREEN := 1
const DISPLAY_MODE_BORDERLESS := 2
const DEFAULT_MUSIC_VOLUME := 0.75
const DEFAULT_SFX_VOLUME := 0.85
const DEFAULT_SHOW_CONTROL_HINTS := true
const DISPLAY_RESOLUTIONS := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
]


static func load_into(
	resolution_option: OptionButton,
	display_mode_option: OptionButton,
	music_slider: HSlider,
	sfx_slider: HSlider,
	control_hints_toggle: CheckButton
) -> void:
	resolution_option.clear()
	for resolution in DISPLAY_RESOLUTIONS:
		resolution_option.add_item(
			"%d × %d" % [resolution.x, resolution.y]
		)
	display_mode_option.clear()
	display_mode_option.add_item("窗口")
	display_mode_option.add_item("全屏")
	display_mode_option.add_item("无边框")

	var config := ConfigFile.new()
	var width := 1280
	var height := 720
	var display_mode := DISPLAY_MODE_WINDOWED
	if config.load(SETTINGS_PATH) == OK:
		width = int(config.get_value("display", "width", width))
		height = int(config.get_value("display", "height", height))
		display_mode = int(
			config.get_value("display", "mode", display_mode)
		)

	var resolution_index := 0
	for index in range(DISPLAY_RESOLUTIONS.size()):
		if DISPLAY_RESOLUTIONS[index] == Vector2i(width, height):
			resolution_index = index
			break
	resolution_option.select(resolution_index)
	display_mode = clampi(
		display_mode,
		DISPLAY_MODE_WINDOWED,
		DISPLAY_MODE_BORDERLESS
	)
	display_mode_option.select(display_mode)
	update_resolution_availability(
		resolution_option,
		display_mode
	)
	music_slider.value = clampf(
		float(
			config.get_value(
				"audio",
				"music_volume",
				DEFAULT_MUSIC_VOLUME
			)
		) * 100.0,
		0.0,
		100.0
	)
	sfx_slider.value = clampf(
		float(
			config.get_value(
				"audio",
				"sfx_volume",
				DEFAULT_SFX_VOLUME
			)
		) * 100.0,
		0.0,
		100.0
	)
	control_hints_toggle.button_pressed = bool(
		config.get_value(
			"interface",
			"show_control_hints",
			DEFAULT_SHOW_CONTROL_HINTS
		)
	)
	apply_audio(music_slider.value, sfx_slider.value)


static func update_resolution_availability(
	resolution_option: OptionButton,
	display_mode: int
) -> void:
	resolution_option.disabled = (
		display_mode != DISPLAY_MODE_WINDOWED
	)


static func apply_and_save(
	resolution_option: OptionButton,
	display_mode_option: OptionButton,
	music_slider: HSlider,
	sfx_slider: HSlider,
	control_hints_toggle: CheckButton
) -> void:
	var resolution_index := clampi(
		resolution_option.selected,
		0,
		DISPLAY_RESOLUTIONS.size() - 1
	)
	var resolution: Vector2i = DISPLAY_RESOLUTIONS[
		resolution_index
	]
	var display_mode := clampi(
		display_mode_option.selected,
		DISPLAY_MODE_WINDOWED,
		DISPLAY_MODE_BORDERLESS
	)
	if DisplayServer.get_name() != "headless":
		apply_display(resolution, display_mode)
	apply_audio(music_slider.value, sfx_slider.value)

	var config := ConfigFile.new()
	config.set_value("display", "width", resolution.x)
	config.set_value("display", "height", resolution.y)
	config.set_value("display", "mode", display_mode)
	config.set_value(
		"audio",
		"music_volume",
		music_slider.value / 100.0
	)
	config.set_value(
		"audio",
		"sfx_volume",
		sfx_slider.value / 100.0
	)
	config.set_value(
		"interface",
		"show_control_hints",
		control_hints_toggle.button_pressed
	)
	config.save(SETTINGS_PATH)


static func apply_audio(
	music_percent: float,
	sfx_percent: float
) -> void:
	_set_bus_linear_volume(&"Music", music_percent / 100.0)
	_set_bus_linear_volume(&"SFX", sfx_percent / 100.0)


static func apply_display(
	resolution: Vector2i,
	display_mode: int
) -> void:
	match display_mode:
		DISPLAY_MODE_FULLSCREEN:
			DisplayServer.window_set_flag(
				DisplayServer.WINDOW_FLAG_BORDERLESS,
				false
			)
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_FULLSCREEN
			)
		DISPLAY_MODE_BORDERLESS:
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_WINDOWED
			)
			DisplayServer.window_set_flag(
				DisplayServer.WINDOW_FLAG_BORDERLESS,
				true
			)
			var screen := DisplayServer.window_get_current_screen()
			DisplayServer.window_set_size(
				DisplayServer.screen_get_size(screen)
			)
			DisplayServer.window_set_position(
				DisplayServer.screen_get_position(screen)
			)
		_:
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_WINDOWED
			)
			DisplayServer.window_set_flag(
				DisplayServer.WINDOW_FLAG_BORDERLESS,
				false
			)
			DisplayServer.window_set_size(resolution)
			_center_window(resolution)


static func _center_window(resolution: Vector2i) -> void:
	var screen := DisplayServer.window_get_current_screen()
	var screen_position := DisplayServer.screen_get_position(screen)
	var screen_size := DisplayServer.screen_get_size(screen)
	DisplayServer.window_set_position(
		screen_position + (screen_size - resolution) / 2
	)


static func _set_bus_linear_volume(
	bus_name: StringName,
	linear_volume: float
) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	var volume_db := (
		-80.0
		if linear_volume <= 0.0001
		else linear_to_db(linear_volume)
	)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
