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
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var companion_manager := player.get_node(
		"CompanionManager"
	) as CompanionManager
	var status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/CompanionStatus"
	) as Label
	var start_room := room_manager.current_room as WeaponSelectionRoom

	await _enter_choice(
		player,
		start_room.character_selector.get_choice_global_position(0)
	)
	await _enter_choice(
		player,
		start_room.choice_selector.get_choice_global_position(0)
	)
	await _enter_choice(
		player,
		start_room.companion_selector.get_choice_global_position(0)
	)

	if (
		not start_room.is_completed
		or not companion_manager.is_companion(&"spore_companion")
		or companion_manager.active_companion == null
		or not status.text.contains("孢子侍从")
	):
		push_error("Physical companion choice did not spawn the partner.")
		quit(1)
		return

	var active := companion_manager.active_companion
	var start_distance := active.global_position.distance_to(
		player.global_position + active.companion_data.follow_offset
	)
	player.global_position += Vector2(120.0, 0.0)
	for _frame in 10:
		await physics_frame
	var end_distance := active.global_position.distance_to(
		player.global_position + active.companion_data.follow_offset
	)
	if end_distance >= start_distance + 120.0:
		push_error("Companion did not follow the player.")
		quit(1)
		return

	var base_context := AttackContext.new(
		active.companion_data.weapon_data.projectile_scene,
		active.companion_data.weapon_data.projectile_data,
		Vector2.RIGHT
	)
	active.gene_link_modifier.modify_attack(base_context)
	if not is_equal_approx(base_context.projectile_data.damage, 5.0):
		push_error("Companion gene link activated without its gene.")
		quit(1)
		return

	gene_manager.add_gene(
		load("res://data/genes/split_gene.tres") as GeneData
	)
	var linked_context := AttackContext.new(
		active.companion_data.weapon_data.projectile_scene,
		active.companion_data.weapon_data.projectile_data,
		Vector2.RIGHT
	)
	active.gene_link_modifier.modify_attack(linked_context)
	if not is_equal_approx(linked_context.projectile_data.damage, 8.75):
		push_error("Split gene did not strengthen the companion attack.")
		quit(1)
		return

	if not room_manager.enter_room(1):
		push_error("Could not enter combat room for companion attack test.")
		quit(1)
		return
	await physics_frame
	var enemy := get_first_node_in_group(
		&"room_enemies"
	) as EnemyController
	enemy.global_position = active.global_position + Vector2(80.0, 0.0)
	var enemy_health := enemy.get_node(
		"HealthComponent"
	) as HealthComponent
	var health_before := enemy_health.current_health
	for _frame in 60:
		await physics_frame
	if enemy_health.current_health >= health_before:
		push_error("Companion did not automatically attack a nearby enemy.")
		quit(1)
		return

	print("Companion system smoke test passed.")
	quit()


func _enter_choice(player: Node2D, position: Vector2) -> void:
	player.global_position = position
	await physics_frame
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame
