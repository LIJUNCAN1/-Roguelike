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
	var relic_manager := player.get_node("RelicManager") as RelicManager
	var relic_status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/RelicStatus"
	) as Label
	var dragon_heart := load(
		"res://data/relics/dragon_heart.tres"
	) as RelicData
	var fire_gene := load(
		"res://data/genes/fire_gene.tres"
	) as GeneData

	if not relic_manager.add_relic(dragon_heart):
		push_error("Dragon Heart could not be added.")
		quit(1)
		return

	var base_context := _create_attack_context()
	relic_manager.modify_attack(base_context)
	if not is_equal_approx(base_context.projectile_data.damage, 10.0):
		push_error("Dragon Heart modified a non-fire attack.")
		quit(1)
		return

	gene_manager.add_gene(fire_gene)
	var fire_context := _create_attack_context()
	var modifier_stack := player.get_node(
		"AttackModifierStack"
	) as AttackModifierStack
	modifier_stack.modify_attack(fire_context)
	if (
		not fire_context.has_tag(&"fire")
		or not is_equal_approx(
			fire_context.projectile_data.damage,
			18.75
		)
	):
		push_error("Dragon Heart did not strengthen the fire route.")
		quit(1)
		return

	if not relic_status.text.contains("龙心"):
		push_error("Relic status UI did not update.")
		quit(1)
		return

	relic_manager.remove_relic(&"dragon_heart")
	var fire_without_relic := _create_attack_context()
	modifier_stack.modify_attack(fire_without_relic)
	if not is_equal_approx(
		fire_without_relic.projectile_data.damage,
		15.0
	):
		push_error("Removing Dragon Heart did not restore fire damage.")
		quit(1)
		return

	gene_manager.clear_genes()
	gene_manager.add_gene(
		load("res://data/genes/split_gene.tres") as GeneData
	)
	var split_without_relic := _create_attack_context()
	modifier_stack.modify_attack(split_without_relic)
	relic_manager.add_relic(
		load("res://data/relics/fission_gland.tres") as RelicData
	)
	var split_context := _create_attack_context()
	modifier_stack.modify_attack(split_context)
	if (
		not split_context.has_tag(&"split")
		or split_context.directions.size() != 3
		or not is_equal_approx(
			split_context.projectile_data.damage,
			split_without_relic.projectile_data.damage * 1.15
		)
		or not is_equal_approx(
			split_context.projectile_data.speed,
			split_without_relic.projectile_data.speed * 1.2
		)
	):
		push_error("Fission Gland did not strengthen split attacks.")
		quit(1)
		return

	print("Relic system smoke test passed.")
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
