extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := (
		load("res://scenes/player/player.tscn") as PackedScene
	).instantiate() as CharacterBody2D
	root.add_child(player)
	await process_frame

	var character_manager := player.get_node(
		"CharacterManager"
	) as CharacterManager
	var trait_manager := player.get_node(
		"CharacterTraitManager"
	) as CharacterTraitManager
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var modifier_stack := player.get_node(
		"AttackModifierStack"
	) as AttackModifierStack

	for gene_path in [
		"res://data/genes/fire_gene.tres",
		"res://data/genes/split_gene.tres",
		"res://data/genes/explosion_gene.tres",
	]:
		gene_manager.add_gene(load(gene_path) as GeneData)
	var original_attack := _make_attack()
	modifier_stack.modify_attack(original_attack)
	if (
		not original_attack.has_tag(&"original_fusion_mastery")
		or original_attack.projectile_data.damage <= 10.0
	):
		push_error("Original Life did not amplify an active fusion.")
		quit(1)
		return

	character_manager.select_character(
		load("res://data/characters/abyss_life.tres") as CharacterData
	)
	gene_manager.add_gene(
		load("res://data/genes/lifesteal_gene.tres") as GeneData
	)
	gene_manager.add_gene(
		load("res://data/genes/frost_gene.tres") as GeneData
	)
	var abyss_attack := _make_attack()
	modifier_stack.modify_attack(abyss_attack)
	var lifesteal_ratio := 0.0
	var slow_duration := 0.0
	for effect in abyss_attack.impact_effects:
		if effect is LifestealImpactEffect:
			lifesteal_ratio = (effect as LifestealImpactEffect).heal_ratio
		elif effect is SlowImpactEffect:
			slow_duration = (effect as SlowImpactEffect).duration
	if (
		not abyss_attack.has_tag(&"abyss_affinity")
		or lifesteal_ratio < 0.75
		or slow_duration < 2.25
	):
		push_error("Abyss Life did not amplify devour/control effects.")
		quit(1)
		return

	character_manager.select_character(
		load("res://data/characters/mechanical_life.tres") as CharacterData
	)
	var energy_before := trait_manager.current_energy
	var mechanical_attack := _make_attack()
	trait_manager.modify_attack(mechanical_attack)
	if (
		not mechanical_attack.has_tag(&"powered_module")
		or mechanical_attack.projectile_data.damage <= 10.0
		or trait_manager.current_energy >= energy_before
	):
		push_error("Mechanical Life did not spend energy on a module attack.")
		quit(1)
		return
	var spent_energy := trait_manager.current_energy
	await create_timer(0.12).timeout
	if trait_manager.current_energy <= spent_energy:
		push_error("Mechanical energy did not regenerate.")
		quit(1)
		return

	print("Character trait smoke test passed.")
	quit()


func _make_attack() -> AttackContext:
	var projectile_data := ProjectileData.new()
	projectile_data.damage = 10.0
	return AttackContext.new(null, projectile_data, Vector2.RIGHT)
