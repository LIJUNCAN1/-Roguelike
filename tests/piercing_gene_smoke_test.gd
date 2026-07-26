extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var piercing_gene := load(
		"res://data/genes/piercing_gene.tres"
	) as GeneData
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame

	var combat_room := TestRoomHelpers.enter_combat_room(main)
	var player := main.get_node("World/Player") as CharacterBody2D
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var enemies: Array[EnemyController] = [
		combat_room.get_node("TestChaser") as EnemyController,
		combat_room.get_node("TestChaserUpper") as EnemyController,
		combat_room.get_node("TestChaserLower") as EnemyController,
	]
	var enemy_positions := [
		Vector2(390, 180),
		Vector2(460, 180),
		Vector2(530, 180),
	]

	for index in enemies.size():
		enemies[index].set_target(null)
		enemies[index].global_position = enemy_positions[index]

	if not gene_manager.add_gene(piercing_gene):
		push_error("Piercing gene could not be added.")
		quit(1)
		return

	player.aim_at(player.global_position + Vector2.RIGHT * 100.0)
	var projectile := player.fire() as Projectile
	if projectile == null:
		push_error("Piercing projectile was not created.")
		quit(1)
		return

	if (
		projectile.projectile_data.max_hits != 3
		or not projectile.attack_tags.has(&"piercing")
	):
		push_error("Piercing projectile data was not modified.")
		quit(1)
		return

	for _frame_index in 120:
		await physics_frame
		if _all_enemies_at_health(
			enemies,
			enemies[0].health_component.max_health - 10.0
		):
			print("Piercing gene smoke test passed.")
			quit()
			return

	push_error("Piercing projectile did not damage three enemies.")
	quit(1)


func _all_enemies_at_health(
	enemies: Array[EnemyController],
	expected_health: float
) -> bool:
	for enemy in enemies:
		var health := enemy.get_node("HealthComponent") as HealthComponent
		if not is_equal_approx(health.current_health, expected_health):
			return false
	return true
