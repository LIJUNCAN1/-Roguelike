extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var pool := load(
		"res://data/rewards/prototype_gene_pool.tres"
	) as GeneRewardPoolData
	if pool == null or pool.genes.size() != 10:
		push_error("Prototype gene pool does not contain 10 genes.")
		quit(1)
		return

	var ids: Dictionary = {}
	for gene in pool.genes:
		if gene == null or gene.id == &"" or ids.has(gene.id):
			push_error("Expanded gene pool contains invalid or duplicate data.")
			quit(1)
			return
		ids[gene.id] = true
	for required_id in [
		&"accelerator",
		&"titan",
		&"twin",
		&"venom",
		&"frost",
	]:
		if not ids.has(required_id):
			push_error("Expanded gene pool is missing a new gene.")
			quit(1)
			return

	var player_scene := load(
		"res://scenes/player/player.tscn"
	) as PackedScene
	var player := player_scene.instantiate() as CharacterBody2D
	root.add_child(player)
	await process_frame
	var genes := player.get_node("GeneManager") as GeneManager
	var evolution := player.get_node(
		"EvolutionSystem"
	) as EvolutionSystem
	genes.add_gene(load("res://data/genes/split_gene.tres") as GeneData)
	genes.add_gene(load("res://data/genes/venom_gene.tres") as GeneData)
	if not evolution.is_evolution(&"plague_hive"):
		push_error("Split and venom did not trigger Plague Hive.")
		quit(1)
		return

	var forge_data := load(
		"res://data/bosses/forge_core.tres"
	) as BossData
	if (
		forge_data == null
		or forge_data.phases.size() != 2
		or forge_data.max_health <= 240.0
	):
		push_error("Forge Core boss content is invalid.")
		quit(1)
		return

	print("Expanded gene content smoke test passed.")
	quit()
