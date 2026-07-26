extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame
	await process_frame

	var room_manager := main.get_node("RoomManager") as RoomManager
	room_manager.random_route_data = load(
		"res://data/rooms/prototype_legacy_route.tres"
	) as RandomRouteData
	if not room_manager.restart_run(20260726):
		push_error("Could not load the isolated legacy flow fixture.")
		quit(1)
		return
	var player := main.get_node("World/Player") as CharacterBody2D
	var player_health := player.get_node(
		"HealthComponent"
	) as HealthComponent
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var relic_manager := player.get_node("RelicManager") as RelicManager
	var evolution_system := player.get_node(
		"EvolutionSystem"
	) as EvolutionSystem

	if not _current_room_is(room_manager, &"start"):
		quit(1)
		return

	var weapon_room := room_manager.current_room as WeaponSelectionRoom
	if weapon_room == null or weapon_room.is_completed:
		push_error("Start room did not wait for a weapon organ.")
		quit(1)
		return
	player.global_position = (
		weapon_room.character_selector.get_choice_global_position(0)
	)
	await physics_frame
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame
	if (
		weapon_room.selected_character == null
		or weapon_room.selected_character.id != &"original_life"
	):
		push_error("Physical character chamber did not select a role.")
		quit(1)
		return
	player.global_position = (
		weapon_room.choice_selector.get_choice_global_position(0)
	)
	await physics_frame
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame
	if (
		weapon_room.is_completed
		or weapon_room.selected_organ == null
		or weapon_room.selected_organ.id != &"needle_organ"
	):
		push_error("Physical weapon chamber did not select an organ.")
		quit(1)
		return
	player.global_position = (
		weapon_room.companion_selector.get_choice_global_position(0)
	)
	await physics_frame
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame
	if (
		not weapon_room.is_completed
		or weapon_room.selected_companion == null
		or weapon_room.selected_companion.id != &"spore_companion"
	):
		push_error("Physical companion chamber did not select a partner.")
		quit(1)
		return

	gene_manager.add_gene(
		load("res://data/genes/fire_gene.tres") as GeneData
	)
	player_health.invulnerability_remaining = 0.0
	player_health.take_damage(30.0)

	if not room_manager.advance_room():
		push_error("Could not advance from start to combat.")
		quit(1)
		return

	if not _current_room_is(room_manager, &"combat"):
		quit(1)
		return

	if room_manager.advance_room():
		push_error("Combat room advanced before enemies were defeated.")
		quit(1)
		return

	if not _room_enemies_target_player(room_manager.current_room, player):
		quit(1)
		return

	_defeat_current_room_enemies(room_manager.current_room)
	await process_frame
	if not room_manager.current_room.is_completed:
		push_error("Combat room did not complete after clearing enemies.")
		quit(1)
		return

	if not room_manager.advance_room():
		push_error("Could not advance to reward room.")
		quit(1)
		return
	await process_frame

	if not _current_room_is(room_manager, &"reward"):
		quit(1)
		return

	var reward_room := room_manager.current_room as GeneRewardRoom
	if reward_room == null or reward_room.is_completed:
		push_error("Reward room completed before a gene was selected.")
		quit(1)
		return

	if room_manager.advance_room():
		push_error("Reward room advanced before a gene was selected.")
		quit(1)
		return

	if not reward_room.choose_gene(0):
		push_error("Could not select a gene reward.")
		quit(1)
		return

	if (
		not gene_manager.has_gene(&"fire")
		or not evolution_system.is_evolution(&"fire_life")
		or not is_equal_approx(player_health.current_health, 70.0)
	):
		push_error("Persistent player state was lost between rooms.")
		quit(1)
		return

	await process_frame
	if room_manager.pending_room_choices.size() != 2:
		push_error("Reward room did not open two route branches.")
		quit(1)
		return
	var route_exits := room_manager.current_route_exit_selector
	if route_exits == null or not route_exits.is_active:
		push_error("Two physical route exits were not opened.")
		quit(1)
		return
	if room_manager.advance_room():
		push_error("Room advanced without choosing a route branch.")
		quit(1)
		return

	var chosen_branch := room_manager.pending_room_choices[1]
	player.global_position = route_exits.get_exit_global_position(1)
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame
	if room_manager.current_room_index != 3:
		push_error("Walking into the route exit did not change rooms.")
		quit(1)
		return

	var random_combat_data := room_manager.get_current_room_data()
	if (
		random_combat_data == null
		or random_combat_data.id != chosen_branch.id
		or random_combat_data.room_type != RoomData.RoomType.COMBAT
	):
		push_error("Selected branch was not entered.")
		quit(1)
		return
	_defeat_current_room_enemies(room_manager.current_room)
	await process_frame

	if room_manager.pending_room_choices.is_empty():
		room_manager.advance_room()
	if room_manager.pending_room_choices.size() != 2:
		push_error("Event layer did not open two physical entrances.")
		quit(1)
		return

	var abandoned_lab_choice := -1
	for index in room_manager.pending_room_choices.size():
		if room_manager.pending_room_choices[index].id == &"abandoned_lab":
			abandoned_lab_choice = index
			break
	if abandoned_lab_choice < 0:
		push_error("Abandoned laboratory was not offered.")
		quit(1)
		return

	var event_route_exits := room_manager.current_route_exit_selector
	player.global_position = event_route_exits.get_exit_global_position(
		abandoned_lab_choice
	)
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame

	if room_manager.current_room_index != 4:
		push_error("Walking into an event entrance did not change rooms.")
		quit(1)
		return

	if not _current_room_is(room_manager, &"abandoned_lab"):
		quit(1)
		return
	var event_room := room_manager.current_room as EventRoom
	player.global_position = (
		event_room.choice_selector.get_choice_global_position(0)
	)
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame
	if (
		not event_room.is_completed
		or event_room.selected_choice == null
		or event_room.selected_choice.id != &"regeneration_tank"
		or not is_equal_approx(
			player_health.current_health,
			player_health.max_health
		)
	):
		push_error("Laboratory healing choice was not resolved.")
		quit(1)
		return

	if not room_manager.advance_room():
		push_error("Could not advance from event to elite room.")
		quit(1)
		return

	if not _current_room_is(room_manager, &"elite"):
		quit(1)
		return
	_defeat_current_room_enemies(room_manager.current_room)
	await process_frame

	if not room_manager.advance_room():
		push_error("Could not advance to gene shop.")
		quit(1)
		return

	if not _current_room_is(room_manager, &"gene_shop"):
		quit(1)
		return
	var shop_room := room_manager.current_room as GeneShopRoom
	player.global_position = shop_room.leave_area.global_position
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame
	if not shop_room.is_completed:
		push_error("Physical shop exit did not complete the room.")
		quit(1)
		return

	if not room_manager.advance_room():
		push_error("Could not advance to relic reward room.")
		quit(1)
		return

	if not _current_room_is(room_manager, &"relic_reward"):
		quit(1)
		return
	var relic_room := room_manager.current_room as RelicRewardRoom
	if relic_room.offered_relics.size() != 2:
		push_error("Relic room did not offer two relics.")
		quit(1)
		return
	player.global_position = (
		relic_room.choice_selector.get_choice_global_position(0)
	)
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame
	if (
		not relic_room.is_completed
		or relic_room.selected_relic == null
		or relic_manager.get_active_relics().size() != 1
	):
		push_error("Physical relic altar did not grant its relic.")
		quit(1)
		return

	if room_manager.advance_room():
		push_error("Boss branch advanced without an entrance choice.")
		quit(1)
		return

	if room_manager.pending_room_choices.size() != 2:
		push_error("Boss layer did not open two physical entrances.")
		quit(1)
		return
	var boss_route_exits := room_manager.current_route_exit_selector
	var boss_choice := 0
	for index in room_manager.pending_room_choices.size():
		if room_manager.pending_room_choices[index].id == &"boss":
			boss_choice = index
			break
	player.global_position = boss_route_exits.get_exit_global_position(
		boss_choice
	)
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame
	if not _current_room_is(room_manager, &"boss"):
		quit(1)
		return
	_defeat_current_room_enemies(room_manager.current_room)
	await process_frame

	room_manager.advance_room()
	if not room_manager.is_run_complete:
		push_error("Random route did not report completion.")
		quit(1)
		return

	print("Room flow smoke test passed.")
	quit()


func _current_room_is(
	room_manager: RoomManager,
	expected_id: StringName
) -> bool:
	var room_data := room_manager.get_current_room_data()
	if room_data == null or room_data.id != expected_id:
		push_error("Unexpected room in random route.")
		return false
	return true


func _defeat_current_room_enemies(room: RoomController) -> void:
	for node in get_nodes_in_group(&"room_enemies"):
		if not room.is_ancestor_of(node):
			continue
		var enemy := node as EnemyController
		var health := enemy.get_node(
			"HealthComponent"
		) as HealthComponent
		health.take_damage(health.current_health)


func _room_enemies_target_player(
	room: RoomController,
	player: Node2D
) -> bool:
	for node in get_nodes_in_group(&"room_enemies"):
		if not room.is_ancestor_of(node):
			continue
		var enemy := node as EnemyController
		if enemy.target != player:
			push_error("Room enemy was not configured with the player.")
			return false
	return true
