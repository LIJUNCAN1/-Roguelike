extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
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
	var evolution_system := player.get_node(
		"EvolutionSystem"
	) as EvolutionSystem
	var form_anchor := player.get_node(
		"Visuals/FormAnchor"
	) as Node2D
	var evolution_status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/EvolutionStatus"
	) as Label

	if not _assert_form(
		evolution_system,
		form_anchor,
		&"base_life",
		&"BaseLifeVisual"
	):
		quit(1)
		return

	gene_manager.add_gene(
		load("res://data/genes/fire_gene.tres") as GeneData
	)
	if not _assert_form(
		evolution_system,
		form_anchor,
		&"fire_life",
		&"FireLifeVisual"
	):
		quit(1)
		return

	if not evolution_status.text.contains("火焰生命"):
		push_error("Evolution UI did not show fire life.")
		quit(1)
		return

	player.aim_at(player.global_position + Vector2.UP * 100.0)
	var fire_life_projectile := player.fire() as Projectile
	if (
		fire_life_projectile == null
		or not fire_life_projectile.attack_tags.has(
			&"fire_life_form"
		)
	):
		push_error("Fire life attack effect was not applied.")
		quit(1)
		return

	for _frame_index in 30:
		await physics_frame

	gene_manager.add_gene(
		load("res://data/genes/split_gene.tres") as GeneData
	)
	gene_manager.add_gene(
		load("res://data/genes/explosion_gene.tres") as GeneData
	)
	if not _assert_form(
		evolution_system,
		form_anchor,
		&"fire_dragon",
		&"FireDragonVisual"
	):
		quit(1)
		return

	if not evolution_status.text.contains("炎龙"):
		push_error("Evolution UI did not show fire dragon.")
		quit(1)
		return

	player.aim_at(player.global_position + Vector2.UP * 100.0)
	var dragon_projectile := player.fire() as Projectile
	if (
		dragon_projectile == null
		or not dragon_projectile.attack_tags.has(
			&"fire_dragon_form"
		)
		or not is_equal_approx(
			dragon_projectile.projectile_data.damage,
			base_damage * 2.25
		)
	):
		push_error("Fire dragon attack upgrade was not applied.")
		quit(1)
		return

	gene_manager.remove_gene(&"explosion")
	if not evolution_system.is_evolution(&"fire_life"):
		push_error("Evolution did not fall back to fire life.")
		quit(1)
		return

	gene_manager.remove_gene(&"fire")
	if not evolution_system.is_evolution(&"mitosis_life"):
		push_error("Evolution did not fall back to split life.")
		quit(1)
		return

	gene_manager.remove_gene(&"split")
	if not evolution_system.is_evolution(&"base_life"):
		push_error("Evolution did not return to base life.")
		quit(1)
		return

	print("Evolution system smoke test passed.")
	quit()


func _assert_form(
	evolution_system: EvolutionSystem,
	form_anchor: Node2D,
	expected_id: StringName,
	expected_visual_name: StringName
) -> bool:
	if not evolution_system.is_evolution(expected_id):
		push_error("Unexpected active evolution.")
		return false

	if form_anchor.get_child_count() != 1:
		push_error("Evolution visual anchor has an invalid child count.")
		return false

	if form_anchor.get_child(0).name != expected_visual_name:
		push_error("Evolution visual scene was not replaced.")
		return false

	return true
