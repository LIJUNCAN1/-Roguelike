extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var gene_paths := [
		"res://data/genes/fire_gene.tres",
		"res://data/genes/split_gene.tres",
		"res://data/genes/piercing_gene.tres",
		"res://data/genes/lifesteal_gene.tres",
		"res://data/genes/explosion_gene.tres",
	]
	var expected_tags: Array[StringName] = [
		&"fire",
		&"split",
		&"piercing",
		&"lifesteal",
		&"explosion",
	]
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame

	var player := main.get_node("World/Player") as CharacterBody2D
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var projectiles := main.get_node("World/Projectiles") as Node2D

	for gene_path in gene_paths:
		if not gene_manager.add_gene(load(gene_path) as GeneData):
			push_error("A gene could not be added to the full build.")
			quit(1)
			return

	player.aim_at(player.global_position + Vector2.UP * 100.0)
	if player.fire() == null or projectiles.get_child_count() != 3:
		push_error("Five-gene build did not create split projectiles.")
		quit(1)
		return

	for child in projectiles.get_children():
		var projectile := child as Projectile
		if (
			not is_equal_approx(projectile.projectile_data.damage, 15.0)
			or projectile.projectile_data.max_hits != 3
			or projectile.impact_effects.size() != 2
		):
			push_error("Five-gene projectile data is incomplete.")
			quit(1)
			return

		for expected_tag in expected_tags:
			if not projectile.attack_tags.has(expected_tag):
				push_error("Five-gene projectile is missing a tag.")
				quit(1)
				return

	print("Five-gene combination smoke test passed.")
	quit()
