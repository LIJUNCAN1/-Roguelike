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
	var player := main.get_node("World/Player") as CharacterBody2D
	var player_health := player.get_node(
		"HealthComponent"
	) as HealthComponent
	var boss_index := room_manager.route_data.rooms.size() - 1
	room_manager.route_data.rooms[boss_index] = load(
		"res://data/rooms/boss_room.tres"
	) as RoomData
	if not room_manager.enter_room(boss_index):
		push_error("Could not enter the boss room.")
		quit(1)
		return
	await physics_frame
	await process_frame

	var boss := room_manager.current_room.get_node_or_null(
		"GeneDevourer"
	) as BossController
	if (
		boss == null
		or boss.boss_data == null
		or boss.boss_data.phases.size() != 2
		or not is_equal_approx(
			boss.health_component.max_health,
			240.0 * (1.0 + float(boss_index) * 0.08)
		)
	):
		push_error("Gene Devourer boss data was not configured.")
		quit(1)
		return

	player.global_position = boss.global_position + Vector2(30.0, 0.0)
	var health_before := player_health.current_health
	boss.attack_cooldown_remaining = 0.0
	await physics_frame
	await physics_frame
	if (
		boss.telegraph_remaining <= 0.0
		or boss.active_indicator == null
		or player_health.current_health != health_before
	):
		push_error("Boss attack did not begin with a safe telegraph.")
		quit(1)
		return

	player.global_position = boss.pending_attack_position + Vector2(90.0, 0.0)
	for _frame in 65:
		await physics_frame
	if player_health.current_health != health_before:
		push_error("Player could not evade the telegraphed boss attack.")
		quit(1)
		return

	player.global_position = boss.global_position + Vector2(20.0, 0.0)
	boss.attack_cooldown_remaining = 0.0
	await physics_frame
	await physics_frame
	for _frame in 65:
		await physics_frame
	if not is_equal_approx(
		player_health.current_health,
		health_before - 16.0
	):
		push_error("Boss attack did not damage a player inside the area.")
		quit(1)
		return

	boss.health_component.take_damage(230.0, player)
	if (
		boss.current_phase_index != 1
		or boss.current_phase == null
		or boss.current_phase.display_name != "狂噬形态"
		or not is_equal_approx(
			boss.movement_component.move_speed,
			86.0
		)
		or not is_equal_approx(
			boss.current_phase.attack.radius,
			58.0
		)
	):
		push_error("Boss did not enter its data-driven second phase.")
		quit(1)
		return

	boss.health_component.take_damage(999.0, player)
	await physics_frame
	await process_frame
	if not room_manager.current_room.is_completed:
		push_error("Boss room did not complete after the boss died.")
		quit(1)
		return

	print("Boss system smoke test passed.")
	quit()
