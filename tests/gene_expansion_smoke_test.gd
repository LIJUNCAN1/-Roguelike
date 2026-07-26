extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var pool := load(
		"res://data/rewards/prototype_gene_pool.tres"
	) as GeneRewardPoolData
	if pool == null or pool.genes.size() != 30:
		push_error("Expanded gene library is not complete.")
		quit(1)
		return
	var ids: Dictionary = {}
	for gene in pool.genes:
		if (
			gene == null
			or gene.id.is_empty()
			or ids.has(gene.id)
			or gene.display_name.is_empty()
			or gene.description.is_empty()
			or gene.tags.is_empty()
			or gene.series_id.is_empty()
			or (
				gene.effects.is_empty()
				and gene.passive_effects.is_empty()
			)
		):
			push_error("A gene has incomplete data or no combat effect.")
			quit(1)
			return
		ids[gene.id] = true
	for required_id in [
		&"lightning", &"ice_crystal", &"piercing_boost",
		&"critical", &"tracking", &"gigantism", &"carapace",
		&"wings", &"tentacle", &"regeneration",
		&"time_dilation", &"black_hole", &"replication",
		&"devour", &"soul_absorption",
	]:
		if not ids.has(required_id):
			push_error("A required expanded gene is missing.")
			quit(1)
			return

	var player := (
		load("res://scenes/player/player.tscn") as PackedScene
	).instantiate() as CharacterBody2D
	root.add_child(player)
	await process_frame
	var genes := player.get_node("GeneManager") as GeneManager
	var health := player.get_node("HealthComponent") as HealthComponent
	var movement := player.get_node(
		"MovementComponent"
	) as MovementComponent
	genes.add_gene(load("res://data/genes/carapace_gene.tres") as GeneData)
	genes.add_gene(load("res://data/genes/wings_gene.tres") as GeneData)
	genes.add_gene(
		load("res://data/genes/regeneration_gene.tres") as GeneData
	)
	await process_frame
	if (
		health.max_health <= 100.0
		or health.damage_taken_multiplier >= 1.0
		or movement.move_speed <= 120.0
	):
		push_error("Body gene passives were not applied.")
		quit(1)
		return
	health.invulnerability_remaining = 0.0
	health.take_damage(10.0)
	var damaged_health := health.current_health
	await create_timer(0.15).timeout
	if health.current_health <= damaged_health:
		push_error("Regeneration gene did not restore health.")
		quit(1)
		return

	var attack := _make_attack()
	for gene_path in [
		"res://data/genes/critical_gene.tres",
		"res://data/genes/tracking_gene.tres",
		"res://data/genes/black_hole_gene.tres",
	]:
		var gene := load(gene_path) as GeneData
		for effect in gene.effects:
			effect.apply(attack)
	if (
		attack.projectile_data.critical_chance <= 0.0
		or attack.projectile_data.homing_strength <= 0.0
		or attack.impact_effects.is_empty()
		or not attack.has_tag(&"black_hole")
	):
		push_error("Advanced projectile genes did not alter combat data.")
		quit(1)
		return

	for reward_path in [
		"res://data/rewards/primordial_gene_pool.tres",
		"res://data/rewards/abyss_gene_pool.tres",
		"res://data/rewards/mechanical_gene_pool.tres",
	]:
		var reward_pool := load(reward_path) as GeneRewardPoolData
		if reward_pool == null or reward_pool.genes.size() != 10:
			push_error("A chapter reward pool is incomplete.")
			quit(1)
			return

	print("Gene expansion smoke test passed.")
	quit()


func _make_attack() -> AttackContext:
	var data := ProjectileData.new()
	data.damage = 10.0
	return AttackContext.new(null, data, Vector2.RIGHT)
