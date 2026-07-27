extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
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
		or title.codex_button == null
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
		title.credits_button,
		title.codex_button,
		title.quit_button,
	]
	for button in styled_buttons:
		if not button is TechMenuButton:
			push_error("A title menu button is missing its tech frame.")
			quit(1)
			return
	if (
		title.has_node("Interface/Menu/Content/VersionButton")
		or title.version_label.text != TitleScreen.CURRENT_VERSION
	):
		push_error("Version information was not moved to the corner.")
		quit(1)
		return
	if not title.start_button.has_focus():
		push_error("Start button did not receive the initial highlight.")
		quit(1)
		return

	title.open_settings()
	if (
		not title.settings_panel.visible
		or title.menu.visible
		or title.resolution_option.item_count != 4
		or title.display_mode_option.item_count != 3
	):
		push_error("Display settings menu was not configured.")
		quit(1)
		return
	title.close_submenu()

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
	if (
		pause_menu.is_pause_visible()
		or paused
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
