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
		or title.quit_button == null
		or title.game_scene_path != "res://scenes/main/main.tscn"
	):
		push_error("Title screen was not configured.")
		quit(1)
		return

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
