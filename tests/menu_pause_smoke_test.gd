extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1280, 720)
	var title_scene := load(
		"res://scenes/ui/title_screen.tscn"
	) as PackedScene
	var title := title_scene.instantiate() as TitleScreen
	root.add_child(title)
	current_scene = title
	await process_frame

	if (
		title.start_button == null
		or title.meta_button == null
		or title.quit_button == null
		or title.game_scene_path != "res://scenes/main/main.tscn"
	):
		push_error("Title screen was not configured.")
		quit(1)
		return

	var styled_buttons: Array[Button] = [
		title.start_button,
		title.settings_button,
		title.roadmap_button,
		title.quit_button,
	]
	for button in styled_buttons:
		if not button is TechMenuButton:
			push_error("A title menu button is missing its tech frame.")
			quit(1)
			return
		if button.custom_minimum_size.y > 56.0:
			push_error("Title menu buttons were not compacted.")
			quit(1)
			return
	if (
		title.menu.size.x > 440.0
		or title.menu_backdrop.size.y != 720.0
		or title.get_node("Interface").transform.x != Vector2(1, 0)
		or int(ProjectSettings.get_setting(
			"display/window/size/viewport_width"
		)) != 1280
		or int(ProjectSettings.get_setting(
			"display/window/size/viewport_height"
		)) != 720
	):
		push_error("Title menu or full-height backdrop sizing is invalid.")
		quit(1)
		return
	if (
		title.has_node("Interface/Menu/Content/VersionButton")
		or title.has_node("Interface/Menu/Content/CreditsButton")
		or title.has_node("Interface/Menu/Content/CodexButton")
		or title.version_label.text != TitleScreen.CURRENT_VERSION
	):
		push_error("Version information was not moved to the corner.")
		quit(1)
		return
	if (
		not title.start_button.has_focus()
		or title.start_button.hover_amount > 0.01
		or not title.start_button.scale.is_equal_approx(Vector2.ONE)
	):
		push_error("Keyboard focus incorrectly lit or scaled the start button.")
		quit(1)
		return

	title.start_button.mouse_entered.emit()
	await create_timer(0.22).timeout
	if (
		title.start_button.hover_amount < 0.9
		or not title.start_button.scale.is_equal_approx(Vector2.ONE)
	):
		push_error("Title button glow or fixed scale was invalid on hover.")
		quit(1)
		return
	title.start_button.mouse_exited.emit()
	await create_timer(0.32).timeout
	if title.start_button.hover_amount > 0.1:
		push_error("Title button did not gradually dim.")
		quit(1)
		return

	var music_bus := AudioServer.get_bus_index(&"Music")
	var sfx_bus := AudioServer.get_bus_index(&"SFX")
	if (
		music_bus < 0
		or sfx_bus < 0
		or title.music_slider.max_value != 100.0
		or title.sfx_slider.max_value != 100.0
	):
		push_error("Audio settings buses or sliders were not configured.")
		quit(1)
		return
	var original_music := title.music_slider.value
	var original_sfx := title.sfx_slider.value
	title.music_slider.value = 50.0
	title.sfx_slider.value = 25.0
	await process_frame
	if (
		not is_equal_approx(
			AudioServer.get_bus_volume_db(music_bus),
			linear_to_db(0.5)
		)
		or not is_equal_approx(
			AudioServer.get_bus_volume_db(sfx_bus),
			linear_to_db(0.25)
		)
		or title.music_value_label.text != "50%"
		or title.sfx_value_label.text != "25%"
	):
		push_error("Audio settings did not update live volume.")
		quit(1)
		return
	title.music_slider.value = original_music
	title.sfx_slider.value = original_sfx

	title.open_roadmap()
	await process_frame
	if (
		not title.info_panel.visible
		or title.menu.visible
		or not title.info_panel is TechSettingsPanel
		or title.info_panel.size != Vector2(524.0, 334.0)
	):
		push_error("EA roadmap panel did not use the compact tech style.")
		quit(1)
		return
	title.close_submenu()

	title.open_settings()
	await process_frame
	var resolution_control_x: float = title.resolution_option.position.x
	var music_control_x: float = title.music_slider.position.x
	var sfx_control_x: float = title.sfx_slider.position.x
	var music_value_x: float = title.music_value_label.position.x
	var sfx_value_x: float = title.sfx_value_label.position.x
	var music_label: Label = title.settings_panel.get_node(
		"Margin/Content/MusicVolumeRow/Label"
	)
	var sfx_label: Label = title.settings_panel.get_node(
		"Margin/Content/SfxVolumeRow/Label"
	)
	var music_slider_center_y: float = (
		title.music_slider.position.y + title.music_slider.size.y * 0.5
	)
	var sfx_slider_center_y: float = (
		title.sfx_slider.position.y + title.sfx_slider.size.y * 0.5
	)
	var music_label_center_y: float = (
		music_label.position.y + music_label.size.y * 0.5
	)
	var sfx_label_center_y: float = (
		sfx_label.position.y + sfx_label.size.y * 0.5
	)
	var slider_track_height: float = (
		title.music_slider.get_theme_stylebox("slider")
		.get_minimum_size().y
	)
	var apply_idle_style := (
		title.settings_apply_button.get_theme_stylebox("normal")
		as StyleBoxFlat
	)
	if (
		not title.settings_panel.visible
		or title.menu.visible
		or not title.settings_panel is TechSettingsPanel
		or title.settings_panel.size != Vector2(756.0, 476.0)
		or title.resolution_option.item_count != 4
		or title.display_mode_option.item_count != 3
		or title.control_hints_toggle == null
		or title.music_slider.get_theme_icon("grabber") == null
		or title.sfx_slider.get_theme_icon("grabber_highlight") == null
		or not is_equal_approx(resolution_control_x, music_control_x)
		or not is_equal_approx(music_control_x, sfx_control_x)
		or not is_equal_approx(music_value_x, sfx_value_x)
		or not is_equal_approx(music_slider_center_y, music_label_center_y)
		or not is_equal_approx(sfx_slider_center_y, sfx_label_center_y)
		or slider_track_height < 8.0
		or apply_idle_style == null
		or apply_idle_style.shadow_size > 0
	):
		push_error(
			(
				"Display settings menu was not configured: "
				+ "visible=%s menu=%s tech=%s size=%s "
				+ "res=%d mode=%d grabber=%s highlight=%s "
				+ "control_x=(%.1f, %.1f, %.1f) value_x=(%.1f, %.1f) "
				+ "center_y=(%.1f/%.1f, %.1f/%.1f) track=%.1f"
			) % [
				title.settings_panel.visible,
				title.menu.visible,
				title.settings_panel is TechSettingsPanel,
				title.settings_panel.size,
				title.resolution_option.item_count,
				title.display_mode_option.item_count,
				title.music_slider.get_theme_icon("grabber") != null,
				title.sfx_slider.get_theme_icon(
					"grabber_highlight"
				) != null,
				resolution_control_x,
				music_control_x,
				sfx_control_x,
				music_value_x,
				sfx_value_x,
				music_slider_center_y,
				music_label_center_y,
				sfx_slider_center_y,
				sfx_label_center_y,
				slider_track_height,
			]
		)
		quit(1)
		return
	title.settings_apply_button.mouse_entered.emit()
	await create_timer(0.16).timeout
	if not title.settings_apply_button.scale.is_equal_approx(Vector2.ONE):
		push_error("Settings button enlarged on mouse hover.")
		quit(1)
		return
	title.settings_apply_button.mouse_exited.emit()
	title.settings_apply_button.pressed.emit()
	await process_frame
	if title.settings_panel.visible or not title.menu.visible:
		push_error("Applying settings did not return to the main menu.")
		quit(1)
		return

	title.open_meta_upgrades()
	if not title.meta_panel.visible or title.menu.visible:
		push_error("Meta progression menu did not open.")
		quit(1)
		return
	title.close_submenu()
	title.open_gene_codex()
	if (
		not title.codex_panel.visible
		or title.menu.visible
		or not (
			title.codex_panel.get_node(
				"Content/Scroll/Text"
			) as RichTextLabel
		).text.contains("雷电基因")
	):
		push_error("Menu gene codex did not open expanded data.")
		quit(1)
		return
	title.close_submenu()

	title.start_game()
	await process_frame
	await process_frame
	var main := current_scene
	if main == null or main.name != &"Main":
		push_error("Title screen did not enter the game.")
		quit(1)
		return

	var pause_menu := main.get_node("PauseMenu") as PauseMenu
	var pause_panel := pause_menu.get_node("Dimmer/Panel")
	if (
		pause_menu.is_pause_visible()
		or paused
		or not pause_panel is TechSettingsPanel
		or not pause_menu.pause_game()
		or not paused
		or not pause_menu.is_pause_visible()
	):
		push_error("Pause menu did not pause the active run.")
		paused = false
		quit(1)
		return

	pause_menu.resume_game()
	if paused or pause_menu.is_pause_visible():
		push_error("Pause menu did not resume the active run.")
		paused = false
		quit(1)
		return

	pause_menu.pause_game()
	pause_menu.return_to_title()
	await process_frame
	await process_frame
	if (
		paused
		or current_scene == null
		or not current_scene is TitleScreen
	):
		push_error("Pause menu did not return to the title screen.")
		paused = false
		quit(1)
		return

	print("Menu and pause smoke test passed.")
	quit()
