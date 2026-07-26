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
	room_manager.route_data.rooms[3] = load(
		"res://data/rooms/abyss_combat_room.tres"
	) as RoomData
	if not room_manager.enter_room(3):
		push_error("Could not enter the ranged enemy room.")
		quit(1)
		return
	await physics_frame
	await process_frame

	var room := room_manager.current_room
	for enemy_name in ["AbyssChaserUpper", "AbyssChaserLower"]:
		var chaser := room.get_node(enemy_name) as EnemyController
		chaser.set_target(null)
	var shooter := room.get_node(
		"SporeShooter"
	) as RangedEnemyController
	var shots: Array[HostileProjectile] = []
	shooter.projectile_fired.connect(
		func(projectile: HostileProjectile) -> void:
			shots.append(projectile)
	)

	if (
		shooter.ranged_enemy_data == null
		or shooter.ranged_enemy_data.projectile_attack == null
		or shooter.projectile_container == null
		or not is_equal_approx(
			shooter.ranged_enemy_data.projectile_attack.projectile_data.damage,
			6.0
		)
	):
		push_error("Ranged enemy data was not configured by the room.")
		quit(1)
		return

	shooter.global_position = player.global_position + Vector2(150.0, 0.0)
	for _frame in 100:
		await physics_frame
		if player_health.current_health < player_health.max_health:
			break
	if (
		shots.is_empty()
		or not is_equal_approx(player_health.current_health, 94.0)
	):
		push_error("Spore Shooter did not fire a damaging hostile projectile.")
		quit(1)
		return

	shooter.ranged_cooldown_remaining = 999.0
	shooter.global_position = player.global_position + Vector2(50.0, 0.0)
	var distance_before := shooter.global_position.distance_to(
		player.global_position
	)
	for _frame in 8:
		await physics_frame
	var distance_after := shooter.global_position.distance_to(
		player.global_position
	)
	if distance_after <= distance_before:
		push_error("Spore Shooter did not retreat from a close player.")
		quit(1)
		return

	print("Ranged enemy smoke test passed.")
	quit()
