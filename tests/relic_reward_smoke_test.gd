extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame
	await process_frame

	var room_manager := main.get_node("RoomManager") as RoomManager
	var player := main.get_node("World/Player") as Node2D
	var relic_manager := player.get_node("RelicManager") as RelicManager
	if not room_manager.enter_room(6):
		push_error("Could not enter relic reward room.")
		quit(1)
		return
	await process_frame

	var relic_room := room_manager.current_room as RelicRewardRoom
	if (
		relic_room == null
		or relic_room.is_completed
		or relic_room.offered_relics.size() != 2
	):
		push_error("Relic reward room did not offer two choices.")
		quit(1)
		return

	var selected := relic_room.offered_relics[1]
	player.global_position = (
		relic_room.choice_selector.get_choice_global_position(1)
	)
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame

	if (
		not relic_room.is_completed
		or relic_room.selected_relic != selected
		or not relic_manager.has_relic(selected.id)
		or relic_manager.get_active_relics().size() != 1
	):
		push_error("Walking to a relic altar did not grant one relic.")
		quit(1)
		return

	print("Relic reward smoke test passed.")
	quit()
