extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame
	await process_frame

	var player := main.get_node("World/Player") as CharacterBody2D
	var health := player.get_node("HealthComponent") as HealthComponent
	var shake := main.get_node(
		"ScreenShakeComponent"
	) as ScreenShakeComponent
	var start_position := player.global_position
	if not player.start_dash(Vector2.RIGHT):
		push_error("Player dash could not start.")
		quit(1)
		return
	await physics_frame
	await physics_frame
	if (
		player.global_position.x <= start_position.x
		or not health.is_invulnerable()
		or health.take_damage(20.0) != 0.0
	):
		push_error("Dash did not move or protect the player.")
		quit(1)
		return

	for _frame in 30:
		await physics_frame
	if health.is_invulnerable():
		push_error("Dash invulnerability did not expire.")
		quit(1)
		return
	if not is_equal_approx(health.take_damage(10.0), 10.0):
		push_error("Player could not take damage after invulnerability.")
		quit(1)
		return
	await process_frame
	if shake.trauma > 0.0:
		push_error("Player damage unexpectedly triggered screen shake.")
		quit(1)
		return

	var knockback_start := player.global_position
	player.apply_knockback(Vector2.LEFT, 150.0, 0.15)
	await physics_frame
	await physics_frame
	if player.global_position.x >= knockback_start.x:
		push_error("Player knockback did not move the body.")
		quit(1)
		return

	print("Player action smoke test passed.")
	quit()
