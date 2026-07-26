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
	var health := player.get_node("HealthComponent") as HealthComponent
	var gene_manager := player.get_node("GeneManager") as GeneManager
	room_manager.route_data.rooms[4] = load(
		"res://data/rooms/event_room.tres"
	) as RoomData

	if not room_manager.enter_room(4):
		push_error("Could not enter laboratory event room.")
		quit(1)
		return
	await process_frame

	var event_room := room_manager.current_room as EventRoom
	if (
		event_room == null
		or event_room.event_data == null
		or event_room.event_data.choices.size() != 3
	):
		push_error("Laboratory event data was not configured.")
		quit(1)
		return

	player.global_position = (
		event_room.choice_selector.get_choice_global_position(2)
	)
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame

	if (
		not event_room.is_completed
		or event_room.selected_choice == null
		or event_room.selected_choice.id != &"dangerous_mutation"
		or not is_equal_approx(health.current_health, 75.0)
		or gene_manager.get_active_genes().size() != 2
	):
		push_error("Risk event effects were not applied from data.")
		quit(1)
		return

	var symbiosis_data := load(
		"res://data/events/symbiosis_nest_event.tres"
	) as EventData
	var symbiosis_choice := symbiosis_data.choices[0]
	symbiosis_choice.apply(EventContext.new(player, 20260726))
	if (
		symbiosis_choice.id != &"gentle_symbiosis"
		or not is_equal_approx(health.current_health, 100.0)
		or gene_manager.get_active_genes().size() != 3
	):
		push_error("Second event did not compose health and gene effects.")
		quit(1)
		return

	print("Event system smoke test passed.")
	quit()
