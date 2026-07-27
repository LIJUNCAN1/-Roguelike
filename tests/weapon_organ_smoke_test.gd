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
	var weapon_manager := player.get_node(
		"WeaponOrganManager"
	) as WeaponOrganManager
	var weapon_component := player.get_node(
		"WeaponComponent"
	) as WeaponComponent
	var status_label := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/WeaponStatus"
	) as Label
	var weapon_slots := main.get_node(
		"Interface/WeaponSlots"
	) as WeaponSlotsHud
	var start_room := room_manager.current_room as WeaponSelectionRoom

	player.global_position = (
		start_room.character_selector.get_choice_global_position(0)
	)
	await physics_frame
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame
	player.global_position = (
		start_room.choice_selector.get_choice_global_position(1)
	)
	await physics_frame
	await physics_frame
	await physics_frame
	await physics_frame
	await process_frame

	if (
		start_room.is_completed
		or not weapon_manager.is_organ(&"heavy_spore_organ")
		or not is_equal_approx(
			weapon_component.weapon_data.projectile_data.damage,
			18.0
		)
		or not is_equal_approx(
			weapon_component.weapon_data.fire_cooldown,
			0.55
		)
		or not status_label.text.contains("重孢炮")
		or weapon_slots.active_slot != 1
		or weapon_slots.get_slot_organ(0) == null
		or weapon_slots.get_slot_organ(0).id != &"needle_organ"
		or weapon_slots.get_slot_organ(1) == null
		or weapon_slots.get_slot_organ(1).id != &"heavy_spore_organ"
	):
		push_error("Heavy spore organ was not equipped from the chamber.")
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
		push_error("Start room did not complete after companion choice.")
		quit(1)
		return

	player.aim_at(player.global_position + Vector2.RIGHT * 100.0)
	var projectile := player.fire() as Projectile
	if (
		projectile == null
		or not is_equal_approx(
			projectile.projectile_data.damage,
			18.0
		)
		or not is_equal_approx(
			projectile.projectile_data.radius,
			5.0
		)
	):
		push_error("Heavy spore organ did not fire its WeaponData.")
		quit(1)
		return

	if not weapon_manager.reset_to_default():
		push_error("Weapon organ could not reset to default.")
		quit(1)
		return
	if not weapon_manager.is_organ(&"needle_organ"):
		push_error("Default weapon organ was not restored.")
		quit(1)
		return

	print("Weapon organ smoke test passed.")
	quit()
