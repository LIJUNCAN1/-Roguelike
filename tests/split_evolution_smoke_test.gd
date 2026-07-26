extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame
	await process_frame

	var player := main.get_node("World/Player") as CharacterBody2D
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var evolution_system := player.get_node(
		"EvolutionSystem"
	) as EvolutionSystem
	var projectile_container := main.get_node(
		"World/Projectiles"
	) as Node2D
	var form_anchor := player.get_node(
		"Visuals/FormAnchor"
	) as Node2D
	var evolution_status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/EvolutionStatus"
	) as Label

	gene_manager.add_gene(
		load("res://data/genes/split_gene.tres") as GeneData
	)
	if (
		not evolution_system.is_evolution(&"mitosis_life")
		or form_anchor.get_child(0).name != &"MitosisLifeVisual"
		or not evolution_status.text.contains("裂殖生命")
	):
		push_error("Split gene did not activate Mitosis Life.")
		quit(1)
		return

	player.aim_at(player.global_position + Vector2.RIGHT * 100.0)
	var mitosis_projectile := player.fire() as Projectile
	if (
		mitosis_projectile == null
		or projectile_container.get_child_count() != 3
		or not mitosis_projectile.attack_tags.has(&"split")
		or not mitosis_projectile.attack_tags.has(&"mitosis_life_form")
		or not is_equal_approx(
			mitosis_projectile.projectile_data.damage,
			8.5
		)
		or not is_equal_approx(
			mitosis_projectile.projectile_data.speed,
			432.0
		)
	):
		push_error("Mitosis Life attack modifiers were not applied.")
		quit(1)
		return

	for projectile in projectile_container.get_children():
		projectile.queue_free()
	for _frame in 16:
		await physics_frame

	gene_manager.add_gene(
		load("res://data/genes/piercing_gene.tres") as GeneData
	)
	if (
		not evolution_system.is_evolution(&"hive_mother")
		or form_anchor.get_child(0).name != &"HiveMotherVisual"
		or not evolution_status.text.contains("群巢母体")
	):
		push_error("Split and piercing did not activate Hive Mother.")
		quit(1)
		return

	player.aim_at(player.global_position + Vector2.RIGHT * 100.0)
	var hive_projectile := player.fire() as Projectile
	if (
		hive_projectile == null
		or projectile_container.get_child_count() != 6
		or not hive_projectile.attack_tags.has(&"hive_mother_form")
		or not hive_projectile.attack_tags.has(&"hive_volley")
		or not hive_projectile.attack_tags.has(&"piercing")
		or not is_equal_approx(
			hive_projectile.projectile_data.damage,
			7.0
		)
		or hive_projectile.projectile_data.max_hits != 3
	):
		push_error("Hive Mother did not fire six piercing projectiles.")
		quit(1)
		return

	gene_manager.remove_gene(&"piercing")
	if not evolution_system.is_evolution(&"mitosis_life"):
		push_error("Hive Mother did not fall back to Mitosis Life.")
		quit(1)
		return

	print("Split evolution smoke test passed.")
	quit()
