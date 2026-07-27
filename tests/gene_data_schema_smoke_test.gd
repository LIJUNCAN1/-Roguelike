extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var pool := load(
		"res://data/rewards/prototype_gene_pool.tres"
	) as GeneRewardPoolData
	if pool == null or pool.genes.size() != 30:
		push_error("Gene pool could not be loaded for schema migration.")
		quit(1)
		return

	var ids: Dictionary = {}
	var used_categories: Dictionary = {}
	for gene in pool.genes:
		if (
			gene == null
			or gene.id == &""
			or gene.display_name.is_empty()
			or gene.description.is_empty()
			or gene.tags.is_empty()
			or (
				gene.effects.is_empty()
				and gene.passive_effects.is_empty()
			)
			or ids.has(gene.id)
			or gene.get_rarity_name().is_empty()
			or gene.get_category_name().is_empty()
			or gene.get_tags_text().is_empty()
		):
			push_error("An existing gene was not fully migrated.")
			quit(1)
			return
		ids[gene.id] = true
		used_categories[gene.category] = true

	if used_categories.size() < 5:
		push_error("Migrated genes do not exercise the new taxonomy.")
		quit(1)
		return

	var expected_categories := [
		"燃烧系",
		"增殖系",
		"生存系",
		"适应系",
		"深渊系",
		"机械系",
		"元素系",
		"召唤系",
	]
	var schema_probe := GeneData.new()
	var expected_rarity_names := [
		"普通",
		"稀有",
		"史诗",
		"传说",
		"神话",
	]
	var expected_rarity_colors := [
		"#eef4f2",
		"#5aa8ff",
		"#bd68ff",
		"#ff9b35",
		"#ff3f45",
	]
	for rarity_index in expected_rarity_names.size():
		schema_probe.rarity = rarity_index
		if (
			schema_probe.get_rarity_name()
			!= expected_rarity_names[rarity_index]
			or schema_probe.get_rarity_color_hex()
			!= expected_rarity_colors[rarity_index]
		):
			push_error("Gene rarity colors do not match the five tiers.")
			quit(1)
			return
	for category_index in expected_categories.size():
		schema_probe.category = category_index
		if schema_probe.get_category_name() != expected_categories[
			category_index
		]:
			push_error("Gene category schema is incomplete.")
			quit(1)
			return

	var player := (
		load("res://scenes/player/player.tscn") as PackedScene
	).instantiate() as CharacterBody2D
	root.add_child(player)
	await process_frame
	var evolution_system := player.get_node(
		"EvolutionSystem"
	) as EvolutionSystem
	var evolution_ids: Dictionary = {}
	evolution_ids[evolution_system.base_evolution.id] = true
	for evolution in evolution_system.evolutions:
		evolution_ids[evolution.id] = true
	for gene in pool.genes:
		for evolution_id in gene.evolution_links:
			if not evolution_ids.has(evolution_id):
				push_error("Gene references an unknown evolution.")
				quit(1)
				return

	var fire := load("res://data/genes/fire_gene.tres") as GeneData
	if (
		not fire.has_tag(&"fire")
		or not fire.links_to_evolution(&"fire_life")
		or fire.get_category_name() != "燃烧系"
	):
		push_error("Gene metadata query helpers are invalid.")
		quit(1)
		return

	var offer := load(
		"res://data/shops/accelerator_offer.tres"
	) as ShopOfferData
	var offer_text := offer.get_display_text()
	if (
		not offer_text.contains(offer.gene.get_rarity_name())
		or not offer_text.contains(offer.gene.get_category_name())
	):
		push_error("Shop does not read the upgraded gene metadata.")
		quit(1)
		return

	print("Gene data schema smoke test passed.")
	quit()
