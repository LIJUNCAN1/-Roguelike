extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var lifesteal_gene := load(
		"res://data/genes/lifesteal_gene.tres"
	) as GeneData
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame

	var combat_room := TestRoomHelpers.enter_combat_room(main)
	var player := main.get_node("World/Player") as CharacterBody2D
	var player_health := player.get_node(
		"HealthComponent"
	) as HealthComponent
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var enemy := combat_room.get_node("TestChaser") as EnemyController
	var health_status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/HealthStatus"
	) as Label
	enemy.set_target(null)
	player_health.take_damage(50.0)

	if not gene_manager.add_gene(lifesteal_gene):
		push_error("Lifesteal gene could not be added.")
		quit(1)
		return

	player.aim_at(enemy.global_position)
	var projectile := player.fire() as Projectile
	if (
		projectile == null
		or not projectile.attack_tags.has(&"lifesteal")
	):
		push_error("Lifesteal projectile was not configured.")
		quit(1)
		return

	for _frame_index in 120:
		await physics_frame
		if is_equal_approx(player_health.current_health, 55.0):
			if not health_status.text.contains("55"):
				push_error("Player health UI did not show lifesteal.")
				quit(1)
				return
			print("Lifesteal gene smoke test passed.")
			quit()
			return

	push_error("Lifesteal did not restore 50% of dealt damage.")
	quit(1)
