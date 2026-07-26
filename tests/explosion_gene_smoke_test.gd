extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var explosion_gene := load(
		"res://data/genes/explosion_gene.tres"
	) as GeneData
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame

	var combat_room := TestRoomHelpers.enter_combat_room(main)
	var player := main.get_node("World/Player") as CharacterBody2D
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var primary := combat_room.get_node("TestChaser") as EnemyController
	var nearby := combat_room.get_node(
		"TestChaserUpper"
	) as EnemyController
	var distant := combat_room.get_node(
		"TestChaserLower"
	) as EnemyController
	var effects := main.get_node("World/Effects") as Node2D

	primary.set_target(null)
	nearby.set_target(null)
	distant.set_target(null)
	primary.global_position = Vector2(440, 180)
	nearby.global_position = Vector2(460, 200)
	distant.global_position = Vector2(550, 260)

	if not gene_manager.add_gene(explosion_gene):
		push_error("Explosion gene could not be added.")
		quit(1)
		return

	player.aim_at(primary.global_position)
	var projectile := player.fire() as Projectile
	if (
		projectile == null
		or not projectile.attack_tags.has(&"explosion")
	):
		push_error("Explosion projectile was not configured.")
		quit(1)
		return

	for _frame_index in 120:
		await physics_frame
		var primary_health := _get_health(primary)
		var nearby_health := _get_health(nearby)
		var distant_health := _get_health(distant)
		if (
			is_equal_approx(primary_health, 12.0)
			and is_equal_approx(nearby_health, 22.0)
			and is_equal_approx(distant_health, 30.0)
		):
			if not effects.has_node("ExplosionEffect"):
				push_error("Explosion visual effect was not created.")
				quit(1)
				return
			print("Explosion gene smoke test passed.")
			quit()
			return

	push_error("Explosion did not apply the expected area damage.")
	quit(1)


func _get_health(enemy: EnemyController) -> float:
	var health := enemy.get_node("HealthComponent") as HealthComponent
	return health.current_health
