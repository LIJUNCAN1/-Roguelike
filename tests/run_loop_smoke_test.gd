extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame
	await process_frame

	var run_flow := main.get_node(
		"RunFlowController"
	) as RunFlowController
	var result_panel := main.get_node(
		"RunResultPanel"
	) as RunResultPanel
	var room_manager := main.get_node("RoomManager") as RoomManager
	var player := main.get_node("World/Player") as Node2D
	var health := player.get_node("HealthComponent") as HealthComponent
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var relic_manager := player.get_node("RelicManager") as RelicManager
	var weapon_manager := player.get_node(
		"WeaponOrganManager"
	) as WeaponOrganManager
	var character_manager := player.get_node(
		"CharacterManager"
	) as CharacterManager

	gene_manager.add_gene(
		load("res://data/genes/fire_gene.tres") as GeneData
	)
	relic_manager.add_relic(
		load("res://data/relics/dragon_heart.tres") as RelicData
	)
	weapon_manager.equip_organ(
		load(
			"res://data/weapons/organs/heavy_spore_organ.tres"
		) as WeaponOrganData
	)
	character_manager.select_character(
		load("res://data/characters/abyss_life.tres") as CharacterData
	)
	health.take_damage(health.current_health)
	if (
		not run_flow.has_ended
		or run_flow.was_victory
		or not result_panel.visible
		or not paused
	):
		push_error("Player death did not show the defeat result.")
		paused = false
		quit(1)
		return

	if not run_flow.restart_run(123456):
		push_error("Could not restart after defeat.")
		paused = false
		quit(1)
		return
	await process_frame

	if (
		run_flow.has_ended
		or result_panel.visible
		or paused
		or health.is_dead
		or not is_equal_approx(health.current_health, health.max_health)
		or not gene_manager.get_active_genes().is_empty()
		or not relic_manager.get_active_relics().is_empty()
		or not weapon_manager.is_organ(&"needle_organ")
		or not character_manager.is_character(&"original_life")
		or not is_equal_approx(health.max_health, 100.0)
		or room_manager.current_room_index != 0
		or room_manager.current_route_seed != 123456
	):
		push_error("Restart did not reset the run state.")
		paused = false
		quit(1)
		return

	room_manager.run_completed.emit()
	if (
		not run_flow.has_ended
		or not run_flow.was_victory
		or not result_panel.visible
		or not paused
	):
		push_error("Run completion did not show the victory result.")
		paused = false
		quit(1)
		return

	paused = false
	print("Run loop smoke test passed.")
	quit()
