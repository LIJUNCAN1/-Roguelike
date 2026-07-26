extends SceneTree


func _init() -> void:
	var route_data := load(
		"res://data/rooms/prototype_random_route.tres"
	) as ChapterRouteData
	if route_data == null or route_data.chapters.size() != 3:
		push_error("Three-chapter route data could not be loaded.")
		quit(1)
		return

	var route := route_data.generate_route(20260727)
	if route.rooms.size() != 16:
		push_error("Demo route does not contain all chapter nodes.")
		quit(1)
		return

	var expected_ids: Array[StringName] = [
		&"primordial",
		&"abyss",
		&"mechanical",
	]
	var reward_pools: Dictionary = {}
	for chapter_index in route_data.chapters.size():
		var chapter := route_data.chapters[chapter_index]
		if (
			chapter.id != expected_ids[chapter_index]
			or chapter.region == null
			or chapter.reward_pool == null
			or chapter.enemy_ids.is_empty()
			or chapter.boss_room_ids.is_empty()
		):
			push_error("Chapter metadata is incomplete.")
			quit(1)
			return
		reward_pools[chapter.reward_pool.resource_path] = true
		var found_types: Dictionary = {}
		for room_index in range(
			chapter.start_room_index,
			chapter.end_room_index + 1
		):
			var room := route.rooms[room_index]
			if room.region == null or room.region.id != chapter.region.id:
				push_error("A chapter room uses the wrong region visuals.")
				quit(1)
				return
			found_types[room.room_type] = true
		for required_type in [
			RoomData.RoomType.COMBAT,
			RoomData.RoomType.ELITE,
			RoomData.RoomType.REWARD,
			RoomData.RoomType.BOSS,
		]:
			if not found_types.has(required_type):
				push_error("A chapter is missing a required room type.")
				quit(1)
				return

	if reward_pools.size() != 3:
		push_error("Chapters do not have independent reward pools.")
		quit(1)
		return

	for reward_index in [3, 8, 13]:
		var reward_room := route.rooms[reward_index]
		var chapter := route_data.get_chapter_for_room(reward_index)
		if (
			reward_room.gene_reward_pool == null
			or reward_room.gene_reward_pool != chapter.reward_pool
		):
			push_error("Reward room did not inherit its chapter pool.")
			quit(1)
			return

	print("Chapter flow smoke test passed.")
	quit()
