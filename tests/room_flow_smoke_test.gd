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
	var player := main.get_node("World/Player") as CharacterBody2D
	var player_health := player.get_node(
		"HealthComponent"
	) as HealthComponent
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var evolution_system := player.get_node(
		"EvolutionSystem"
	) as EvolutionSystem

	if not _current_room_is(room_manager, &"start"):
		quit(1)
		return

	gene_manager.add_gene(
		load("res://data/genes/fire_gene.tres") as GeneData
	)
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

	if not room_manager.advance_room():
		push_error("Could not advance to elite room.")
		quit(1)
		return

	if not _current_room_is(room_manager, &"elite"):
		quit(1)
		return
	_defeat_current_room_enemies(room_manager.current_room)
	await process_frame

	if not room_manager.advance_room():
		push_error("Could not advance to boss room.")
		quit(1)
		return

	if not _current_room_is(room_manager, &"boss"):
		quit(1)
		return
	_defeat_current_room_enemies(room_manager.current_room)
	await process_frame

	room_manager.advance_room()
	if not room_manager.is_run_complete:
		push_error("Fixed route did not report completion.")
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
		push_error("Unexpected room in fixed route.")
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
