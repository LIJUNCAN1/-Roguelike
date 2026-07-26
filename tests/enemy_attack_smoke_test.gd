extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame
	await process_frame

	var combat_room := TestRoomHelpers.enter_combat_room(main)
	var player := main.get_node("World/Player") as CharacterBody2D
	var player_health := player.get_node(
		"HealthComponent"
	) as HealthComponent
	var player_visuals := player.get_node("Visuals") as Node2D
	var enemy := combat_room.get_node(
		"TestChaser"
	) as EnemyController
	for enemy_name in ["TestChaserUpper", "TestChaserLower"]:
		var other_enemy := combat_room.get_node(
			enemy_name
		) as EnemyController
		other_enemy.set_target(null)

	if (
		enemy.enemy_data.attack_data == null
		or not is_equal_approx(
			enemy.enemy_data.attack_data.damage,
			8.0
		)
		or not is_equal_approx(
			enemy.enemy_data.attack_data.cooldown,
			1.1
		)
	):
		push_error("Enemy melee attack data was not configured.")
		quit(1)
		return

	enemy.global_position = player.global_position + Vector2(20.0, 0.0)
	await physics_frame
	await physics_frame
	if (
		not is_equal_approx(player_health.current_health, 92.0)
		or enemy.contact_cooldown_remaining <= 0.0
		or player_visuals.modulate.is_equal_approx(Color.WHITE)
	):
		push_error("Enemy did not damage the player with hit feedback.")
		quit(1)
		return

	for _frame in 30:
		await physics_frame
	if not is_equal_approx(player_health.current_health, 92.0):
		push_error("Enemy ignored its attack cooldown.")
		quit(1)
		return

	for _frame in 45:
		await physics_frame
	if not is_equal_approx(player_health.current_health, 84.0):
		push_error("Enemy did not attack again after its cooldown.")
		quit(1)
		return

	print("Enemy attack smoke test passed.")
	quit()
