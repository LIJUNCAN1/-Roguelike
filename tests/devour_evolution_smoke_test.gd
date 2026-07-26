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
	var modifier_stack := player.get_node(
		"AttackModifierStack"
	) as AttackModifierStack
	var form_anchor := player.get_node(
		"Visuals/FormAnchor"
	) as Node2D
	var evolution_status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/EvolutionStatus"
	) as Label

	gene_manager.add_gene(
		load("res://data/genes/lifesteal_gene.tres") as GeneData
	)
	if (
		not evolution_system.is_evolution(&"blood_sac_life")
		or form_anchor.get_child(0).name != &"BloodSacLifeVisual"
		or not evolution_status.text.contains("血囊生命")
	):
		push_error("Lifesteal gene did not activate Blood Sac Life.")
		quit(1)
		return

	var blood_context := _create_attack_context()
	modifier_stack.modify_attack(blood_context)
	var blood_lifesteal := _find_lifesteal(blood_context)
	if (
		blood_lifesteal == null
		or not blood_context.has_tag(&"blood_sac_form")
		or not blood_context.has_tag(&"blood_sac_lifesteal")
		or not is_equal_approx(blood_lifesteal.heal_ratio, 0.7)
		or not is_equal_approx(
			blood_context.projectile_data.radius,
			3.45
		)
	):
		push_error("Blood Sac Life attack upgrades were not applied.")
		quit(1)
		return

	gene_manager.add_gene(
		load("res://data/genes/explosion_gene.tres") as GeneData
	)
	if (
		not evolution_system.is_evolution(&"abyss_devourer")
		or form_anchor.get_child(0).name != &"AbyssDevourerVisual"
		or not evolution_status.text.contains("深渊吞噬者")
	):
		push_error("Lifesteal and explosion did not activate Devourer.")
		quit(1)
		return

	var devour_context := _create_attack_context()
	modifier_stack.modify_attack(devour_context)
	var devour_lifesteal := _find_lifesteal(devour_context)
	var devour_explosion := _find_explosion(devour_context)
	if (
		devour_lifesteal == null
		or devour_explosion == null
		or not devour_context.has_tag(&"abyss_devourer_form")
		or not devour_context.has_tag(&"abyss_lifesteal")
		or not devour_context.has_tag(&"devour_burst")
		or not is_equal_approx(
			devour_context.projectile_data.damage,
			11.0
		)
		or not is_equal_approx(devour_lifesteal.heal_ratio, 0.8)
		or not is_equal_approx(devour_explosion.damage, 12.0)
		or not is_equal_approx(devour_explosion.radius, 72.0)
		or not devour_explosion.effect_color.is_equal_approx(
			Color(0.72, 0.08, 0.62, 1.0)
		)
	):
		push_error("Abyss Devourer impact upgrades were not applied.")
		quit(1)
		return

	gene_manager.remove_gene(&"explosion")
	if not evolution_system.is_evolution(&"blood_sac_life"):
		push_error("Devourer did not fall back to Blood Sac Life.")
		quit(1)
		return

	print("Devour evolution smoke test passed.")
	quit()


func _create_attack_context() -> AttackContext:
	var weapon_data := load(
		"res://data/weapons/basic_weapon.tres"
	) as WeaponData
	return AttackContext.new(
		weapon_data.projectile_scene,
		weapon_data.projectile_data,
		Vector2.RIGHT
	)


func _find_lifesteal(
	attack_context: AttackContext
) -> LifestealImpactEffect:
	for effect in attack_context.impact_effects:
		var lifesteal := effect as LifestealImpactEffect
		if lifesteal != null:
			return lifesteal
	return null


func _find_explosion(
	attack_context: AttackContext
) -> ExplosionImpactEffect:
	for effect in attack_context.impact_effects:
		var explosion := effect as ExplosionImpactEffect
		if explosion != null:
			return explosion
	return null
