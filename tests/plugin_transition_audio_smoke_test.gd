extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var enabled_plugins: PackedStringArray = ProjectSettings.get_setting(
		"editor_plugins/enabled",
		PackedStringArray()
	)
	for expected_path in [
		"res://addons/gdfxr/plugin.cfg",
		"res://addons/scene_manager/plugin.cfg",
		"res://addons/sound_manager/plugin.cfg",
	]:
		if not enabled_plugins.has(expected_path):
			_fail("Required plugin is not enabled: %s" % expected_path)
			return
	var scene_manager := root.get_node_or_null("SceneManager")
	var sound_manager := root.get_node_or_null("SoundManager")
	if scene_manager == null or sound_manager == null:
		_fail("Transition or audio plugin Autoload is missing.")
		return
	if (
		sound_manager.sound_effects.bus != "SFX"
		or sound_manager.ui_sounds.bus != "SFX"
		or sound_manager.ambient_sounds.bus != "SFX"
		or sound_manager.music.bus != "Music"
	):
		_fail("Sound Manager is not using the project audio buses.")
		return

	for cue_path in [
		"res://data/audio/cues/attack.tres",
		"res://data/audio/cues/dash.tres",
		"res://data/audio/cues/hurt.tres",
		"res://data/audio/cues/death.tres",
		"res://data/audio/cues/evolution.tres",
		"res://data/audio/cues/boss_phase.tres",
	]:
		var cue := load(cue_path) as AudioCueData
		if (
			cue == null
			or cue.stream == null
			or not cue.stream.resource_path.begins_with(
				"res://assets/audio/generated/"
			)
		):
			_fail("Generated audio cue is missing: %s" % cue_path)
			return

	var title := (
		load("res://scenes/ui/title_screen.tscn") as PackedScene
	).instantiate() as TitleScreen
	root.add_child(title)
	current_scene = title
	await process_frame
	if (
		TitleScreen.START_TRANSITION_OPTIONS["pattern"] != "circle"
		or TitleScreen.MENU_HOVER_SFX == null
		or TitleScreen.MENU_CONFIRM_SFX == null
		or TitleScreen.MENU_TRANSITION_SFX == null
	):
		_fail("Menu transition or UI sound resources are invalid.")
		return
	title.start_game()
	await process_frame
	await process_frame
	if current_scene == null or current_scene.name != &"HubWorld":
		_fail("Scene Manager did not transition from title to hub.")
		return

	print("Plugin transition and audio smoke test passed.")
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
