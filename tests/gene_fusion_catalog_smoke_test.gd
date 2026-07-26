extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := (
		load("res://scenes/player/player.tscn") as PackedScene
	).instantiate() as CharacterBody2D
	root.add_child(player)
	await process_frame
	var genes := player.get_node("GeneManager") as GeneManager
	var fusion_manager := player.get_node(
		"FusionManager"
	) as GeneFusionManager
	var morph := player.get_node(
		"FusionMorphPresenter"
	) as FusionMorphPresenter
	if (
		fusion_manager == null
		or fusion_manager.fusion_recipes.size() != 20
	):
		push_error("GeneFusionManager does not expose 20 builds.")
		quit(1)
		return
	var ids: Dictionary = {}
	for fusion in fusion_manager.fusion_recipes:
		if (
			fusion == null
			or fusion.id.is_empty()
			or ids.has(fusion.id)
			or fusion.display_name.is_empty()
			or fusion.description.is_empty()
			or fusion.required_gene_ids.size() < 3
			or fusion.effects.is_empty()
			or fusion.form_color.a <= 0.0
		):
			push_error("A build has incomplete data.")
			quit(1)
			return
		ids[fusion.id] = true

	for gene_id in [&"lightning", &"split", &"tracking"]:
		genes.add_gene(
			load("res://data/genes/%s_gene.tres" % gene_id) as GeneData
		)
	await process_frame
	if (
		not fusion_manager.has_fusion(&"thunder_swarm")
		or morph.active_fusion == null
		or morph.active_fusion.id != &"thunder_swarm"
	):
		push_error("Thunder Swarm did not trigger its build and form.")
		quit(1)
		return
	var projectile_data := ProjectileData.new()
	projectile_data.damage = 10.0
	var attack := AttackContext.new(
		null,
		projectile_data,
		Vector2.RIGHT
	)
	fusion_manager.modify_attack(attack)
	if (
		not attack.has_tag(&"thunder_swarm_build")
		or attack.projectile_data.damage <= 10.0
		or attack.projectile_data.homing_strength <= 0.0
	):
		push_error("Thunder Swarm did not apply its special effect.")
		quit(1)
		return

	print("Gene fusion catalog smoke test passed.")
	quit()
