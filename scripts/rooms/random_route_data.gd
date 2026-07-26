class_name RandomRouteData
extends Resource

@export var room_pools: Array[RouteRoomPoolData] = []


func generate_route(seed_value: int) -> RunRouteData:
	var generated_route := RunRouteData.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value

	for room_pool in room_pools:
		if room_pool == null:
			continue
		var candidates := room_pool.get_valid_rooms()
		if candidates.is_empty():
			continue
		var selected_index := rng.randi_range(0, candidates.size() - 1)
		generated_route.rooms.append(candidates[selected_index])

	return generated_route


func get_room_choices(
	layer_index: int,
	seed_value: int,
	choice_count: int = 2
) -> Array[RoomData]:
	var choices: Array[RoomData] = []
	if layer_index < 0 or layer_index >= room_pools.size():
		return choices

	var room_pool := room_pools[layer_index]
	if room_pool == null:
		return choices

	choices = room_pool.get_valid_rooms()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + layer_index * 104729
	for index in range(choices.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var room := choices[index]
		choices[index] = choices[swap_index]
		choices[swap_index] = room

	if choices.size() > choice_count:
		choices.resize(choice_count)
	return choices
