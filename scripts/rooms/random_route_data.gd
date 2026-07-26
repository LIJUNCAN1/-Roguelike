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
