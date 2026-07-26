extends SceneTree

const ROUTE_PATH := "res://data/rooms/prototype_random_route.tres"


func _init() -> void:
	var generator := load(ROUTE_PATH) as RandomRouteData
	if generator == null:
		push_error("Could not load random route data.")
		quit(1)
		return

	var first_route := generator.generate_route(20260726)
	var repeated_route := generator.generate_route(20260726)
	if _get_ids(first_route) != _get_ids(repeated_route):
		push_error("The same seed generated different routes.")
		quit(1)
		return

	if not _has_valid_progression(first_route):
		quit(1)
		return

	var generated_sequences: Dictionary = {}
	for seed_value in range(1, 33):
		var route := generator.generate_route(seed_value)
		generated_sequences[str(_get_ids(route))] = true
		if not _has_valid_progression(route):
			quit(1)
			return

	if generated_sequences.size() < 2:
		push_error("Different seeds did not produce route variation.")
		quit(1)
		return

	var branch_choices := generator.get_room_choices(3, 20260726)
	var repeated_choices := generator.get_room_choices(3, 20260726)
	if (
		branch_choices.size() != 2
		or _get_choice_ids(branch_choices) != _get_choice_ids(repeated_choices)
		or branch_choices[0].id == branch_choices[1].id
	):
		push_error("Seeded room branch choices are invalid.")
		quit(1)
		return

	print("Random route smoke test passed.")
	quit()


func _get_ids(route: RunRouteData) -> Array[StringName]:
	var ids: Array[StringName] = []
	for room in route.rooms:
		ids.append(room.id)
	return ids


func _get_choice_ids(choices: Array[RoomData]) -> Array[StringName]:
	var ids: Array[StringName] = []
	for room in choices:
		ids.append(room.id)
	return ids


func _has_valid_progression(route: RunRouteData) -> bool:
	if route == null or route.rooms.size() != 7:
		push_error("Generated route has an invalid room count.")
		return false

	var expected_types: Array[int] = [
		RoomData.RoomType.START,
		RoomData.RoomType.COMBAT,
		RoomData.RoomType.REWARD,
		RoomData.RoomType.COMBAT,
		RoomData.RoomType.EVENT,
		RoomData.RoomType.ELITE,
		RoomData.RoomType.BOSS,
	]
	for index in expected_types.size():
		if route.rooms[index].room_type != expected_types[index]:
			push_error("Generated route broke the required progression.")
			return false
	return true
