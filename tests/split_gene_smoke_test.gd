extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var split_gene := load(
		"res://data/genes/split_gene.tres"
	) as GeneData
	var fire_gene := load(
		"res://data/genes/fire_gene.tres"
	) as GeneData
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame

	var player := main.get_node("World/Player") as CharacterBody2D
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var weapon_component := player.get_node(
		"WeaponComponent"
	) as WeaponComponent
	var base_damage := (
		weapon_component.weapon_data.projectile_data.damage
	)
	var projectiles := main.get_node("World/Projectiles") as Node2D
	var gene_status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/GeneStatus"
	) as Label

	if not gene_manager.add_gene(split_gene):
		push_error("Split gene could not be added.")
		quit(1)
		return

	player.aim_at(player.global_position + Vector2.UP * 100.0)
	if player.fire() == null:
		push_error("Split attack did not create a projectile.")
		quit(1)
		return

	if projectiles.get_child_count() != 3:
		push_error("Split gene did not create three projectiles.")
		quit(1)
		return

	var split_projectiles: Array[Projectile] = []
	for child in projectiles.get_children():
		var projectile := child as Projectile
		split_projectiles.append(projectile)
		if not projectile.attack_tags.has(&"split"):
			push_error("Split projectile is missing the split tag.")
			quit(1)
			return

	if not (
		split_projectiles[0].travel_direction.x
		< split_projectiles[1].travel_direction.x
		and split_projectiles[1].travel_direction.x
		< split_projectiles[2].travel_direction.x
	):
		push_error("Split projectiles did not receive distinct angles.")
		quit(1)
		return

	for _frame_index in 30:
		await physics_frame

	if not gene_manager.add_gene(fire_gene):
		push_error("Fire gene could not combine with split gene.")
		quit(1)
		return

	player.aim_at(player.global_position + Vector2.UP * 100.0)
	if player.fire() == null:
		push_error("Combined attack did not create a projectile.")
		quit(1)
		return

	if projectiles.get_child_count() != 3:
		push_error("Combined melee attack did not create three slashes.")
		quit(1)
		return

	for child_index in range(3):
		var projectile := (
			projectiles.get_child(child_index) as Projectile
		)
		if not (
			projectile.attack_tags.has(&"split")
			and projectile.attack_tags.has(&"fire")
		):
			push_error("Combined projectile is missing gene tags.")
			quit(1)
			return

		if not is_equal_approx(
			projectile.projectile_data.damage,
			base_damage * 1.5
		):
			push_error("Fire damage was not inherited by split shots.")
			quit(1)
			return

	if not (
		gene_status.text.contains("火焰")
		and gene_status.text.contains("分裂")
	):
		push_error("Gene status UI did not show the combination.")
		quit(1)
		return

	print("Split gene smoke test passed.")
	quit()
