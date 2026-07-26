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
	var character_manager := player.get_node(
		"CharacterManager"
	) as CharacterManager
	var movement := player.get_node(
		"MovementComponent"
	) as MovementComponent
	var health := player.get_node("HealthComponent") as HealthComponent
	var evolution := player.get_node(
		"EvolutionSystem"
	) as EvolutionSystem
	var status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/CharacterStatus"
	) as Label
	var start_room := room_manager.current_room as WeaponSelectionRoom

	player.global_position = (
		start_room.character_selector.get_choice_global_position(1)
	)
	await physics_frame
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame

	if (
		start_room.selected_character == null
		or not character_manager.is_character(&"abyss_life")
		or not is_equal_approx(health.max_health, 125.0)
		or not is_equal_approx(health.current_health, 125.0)
		or not is_equal_approx(movement.move_speed, 105.0)
		or not evolution.is_evolution(&"abyss_base_life")
		or not status.text.contains("深渊生命")
	):
		push_error("Abyss character data was not fully applied.")
		quit(1)
		return

	if start_room.is_completed:
		push_error("Start room completed before selecting a weapon.")
		quit(1)
		return
	if start_room.character_choices.size() != 3:
		push_error("Start room did not expose three character choices.")
		quit(1)
		return

	player.global_position = (
		start_room.choice_selector.get_choice_global_position(0)
	)
	await physics_frame
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame
	if start_room.is_completed:
		push_error("Start room completed before selecting a companion.")
		quit(1)
		return

	player.global_position = (
		start_room.companion_selector.get_choice_global_position(1)
	)
	await physics_frame
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame
	if not start_room.is_completed:
		push_error("Start preparation did not complete after three choices.")
		quit(1)
		return

	if not character_manager.select_character(
		load(
			"res://data/characters/mechanical_life.tres"
		) as CharacterData
	):
		push_error("Mechanical character could not be selected.")
		quit(1)
		return
	if (
		not character_manager.is_character(&"mechanical_life")
		or not is_equal_approx(health.max_health, 85.0)
		or not is_equal_approx(movement.move_speed, 135.0)
		or not evolution.is_evolution(&"mechanical_base_life")
		or not status.text.contains("机械生命")
	):
		push_error("Mechanical character data was not fully applied.")
		quit(1)
		return

	print("Character system smoke test passed.")
	quit()
