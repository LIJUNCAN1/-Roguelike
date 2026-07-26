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
	var fusion_manager := player.get_node(
		"FusionManager"
	) as FusionManager
	var fusion_status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/FusionStatus"
	) as Label

	gene_manager.add_gene(
		load("res://data/genes/fire_gene.tres") as GeneData
	)
	gene_manager.add_gene(
		load("res://data/genes/split_gene.tres") as GeneData
	)
	if fusion_manager.has_fusion(&"fire_burst"):
		push_error("Fusion activated before all requirements were met.")
		quit(1)
		return

	gene_manager.add_gene(
		load("res://data/genes/explosion_gene.tres") as GeneData
	)
	if not fusion_manager.has_fusion(&"fire_burst"):
		push_error("Fire burst fusion did not activate.")
		quit(1)
		return

	if not fusion_status.text.contains("炎爆流"):
		push_error("Fusion status UI did not show the active fusion.")
		quit(1)
		return

	player.aim_at(player.global_position + Vector2.UP * 100.0)
	var projectile := player.fire() as Projectile
	if projectile == null:
		push_error("Fusion attack did not create a projectile.")
		quit(1)
		return

	if not projectile.attack_tags.has(&"fire_burst_fusion"):
		push_error("Fusion attack tag was not applied.")
		quit(1)
		return

	var explosion := _find_explosion_effect(projectile)
	if (
		explosion == null
		or not is_equal_approx(explosion.damage, 16.0)
		or not is_equal_approx(explosion.radius, 72.0)
	):
		push_error("Fusion did not upgrade explosion damage and radius.")
		quit(1)
		return

	gene_manager.remove_gene(&"explosion")
	if fusion_manager.has_fusion(&"fire_burst"):
		push_error("Fusion did not deactivate after losing a requirement.")
		quit(1)
		return

	if not fusion_status.text.contains("未激活"):
		push_error("Fusion status UI did not clear.")
		quit(1)
		return

	print("Fire burst fusion smoke test passed.")
	quit()


func _find_explosion_effect(
	projectile: Projectile
) -> ExplosionImpactEffect:
	for impact_effect in projectile.impact_effects:
		var explosion := impact_effect as ExplosionImpactEffect
		if explosion != null:
			return explosion
	return null
