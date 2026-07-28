extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1280, 720)
	var title_packed := load(
		"res://scenes/ui/title_screen.tscn"
	) as PackedScene
	var title := title_packed.instantiate() as TitleScreen
	root.add_child(title)
	current_scene = title
	await process_frame
	if title.game_scene_path != "res://scenes/hub/hub_world.tscn":
		_fail("Title screen does not route to the hub.")
		return

	title.start_game()
	await process_frame
	await process_frame
	var hub := current_scene as HubWorld
	if hub == null:
		_fail("Title to hub transition failed.")
		return
	hub._start_adventure()
	await process_frame
	await process_frame
	var main := current_scene
	if main == null or main.name != &"Main":
		_fail("Hub to combat transition failed.")
		return
	var vitals := main.get_node_or_null(
		"Interface/PlayerVitals"
	) as Control
	var result_panel := main.get_node_or_null(
		"RunResultPanel"
	) as RunResultPanel
	if (
		vitals == null
		or result_panel == null
		or result_panel.return_hub_button == null
	):
		_fail("Combat HUD or return-to-hub control was damaged.")
		return

	result_panel.return_to_hub()
	await process_frame
	await process_frame
	if current_scene == null or current_scene.name != &"HubWorld":
		_fail("Combat to hub transition failed.")
		return

	print("Hub scene flow smoke test passed.")
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
