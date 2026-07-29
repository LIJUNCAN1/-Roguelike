extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame

	var combat_room := TestRoomHelpers.enter_combat_room(main)
	var player := main.get_node("World/Player") as CharacterBody2D
	var enemy := combat_room.get_node("TestChaser") as CharacterBody2D
	var health := enemy.get_node("HealthComponent") as HealthComponent
	var weapon_component := player.get_node(
		"WeaponComponent"
	) as WeaponComponent
	var base_damage := (
		weapon_component.weapon_data.projectile_data.damage
	)
	enemy.set_target(null)
	enemy.global_position = player.global_position + Vector2(28, 0)
	health.configure(base_damage * 2.0)

	player.aim_at(enemy.global_position)
	if player.fire() == null:
		push_error("First damage test projectile was not created.")
		quit(1)
		return

	if not await _wait_for_health(health, base_damage):
		push_error("Projectile did not apply data-driven damage.")
		quit(1)
		return

	for _frame_index in 30:
		await physics_frame
	player.aim_at(enemy.global_position)
	if player.fire() == null:
		push_error("Second damage test projectile was not created.")
		quit(1)
		return

	if not await _wait_for_death(enemy):
		push_error("Enemy was not removed after health reached zero.")
		quit(1)
		return

	print("Damage and death smoke test passed.")
	quit()


func _wait_for_health(
	health: HealthComponent,
	expected_health: float
) -> bool:
	for _frame_index in 90:
		await physics_frame
		if is_equal_approx(health.current_health, expected_health):
			return true
	return false


func _wait_for_death(enemy: Node) -> bool:
	for _frame_index in 90:
		await physics_frame
		if not is_instance_valid(enemy):
			return true
	return false
