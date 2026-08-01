extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1280, 720)
	var main := (
		load("res://scenes/main/main.tscn") as PackedScene
	).instantiate()
	root.add_child(main)
	await physics_frame
	await process_frame

	var room_manager := main.get_node("RoomManager") as RoomManager
	var room := room_manager.current_room as StartArenaRoom
	var player := main.get_node("World/Player") as CharacterBody2D
	var camera := main.get_node("World/Camera2D") as RoomCameraController
	if room == null:
		_fail("The opening room is not StartArenaRoom.")
		return
	if room.get_room_bounds() != Rect2(0, 0, 1920, 1080):
		_fail("Opening room is not three by three screens.")
		return
	if player.global_position != Vector2(960, 540):
		_fail("Player did not spawn at the large room center.")
		return
	if (
		camera.limit_left != 0
		or camera.limit_top != 0
		or camera.limit_right != 1920
		or camera.limit_bottom != 1080
	):
		_fail("Camera limits do not match the large room.")
		return
	var ground := room.get_node("TileMapBuilder/Ground") as TileMapLayer
	if ground.get_used_cells().size() < 8000:
		_fail("Editable TileMapLayer ground was not generated.")
		return
	if not room.choice_selector.visible or not player.input_enabled:
		_fail("Walk-over opening item selector is not active.")
		return
	if room.offered_items.size() != 2:
		_fail("Opening item selector did not offer exactly two items.")
		return
	room.call("_on_item_entered", 0)
	if room.selected_item == null:
		_fail("Opening walk-over item could not be collected.")
		return
	await process_frame
	if room.choice_selector.visible or not player.input_enabled:
		_fail("Opening item pedestals did not disappear after collection.")
		return
	var relic_manager := player.get_node("RelicManager") as RelicManager
	var inventory := main.get_node(
		"Interface/ItemInventory/ItemList"
	) as VBoxContainer
	var pickup_icon := player.get_node(
		"ItemPickupFeedback/Icon"
	) as Sprite2D
	if (
		not relic_manager.has_relic(room.selected_item.id)
		or inventory.get_child_count() != 1
		or not pickup_icon.visible
	):
		_fail("Collected item did not update effects, feedback and inventory.")
		return
	var base_data := ProjectileData.new()
	base_data.damage = 10.0
	var item_context := AttackContext.new(null, base_data, Vector2.RIGHT)
	relic_manager.modify_attack(item_context)
	if item_context.projectile_data.damage == 10.0 and (
		item_context.projectile_data.speed == base_data.speed
		and item_context.projectile_data.radius == base_data.radius
		and item_context.projectile_data.max_hits == base_data.max_hits
	):
		_fail("Opening item has no independent combat effect.")
		return
	if room.wave_spawner.current_wave_index != 0:
		_fail("First wave did not start after gene selection.")
		return
	room.wave_spawner.call("_spawn_next_wave")
	room.wave_spawner.call("_spawn_next_wave")
	for node in get_nodes_in_group(&"room_enemies"):
		if not room.is_ancestor_of(node):
			continue
		var health := node.get_node_or_null("HealthComponent") as HealthComponent
		if health != null and not health.is_dead:
			health.take_damage(100000.0)
	await process_frame
	if not room.is_completed:
		_fail("Room did not complete after all configured waves were cleared.")
		return
	print("Start arena and fixed wave smoke test passed.")
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
