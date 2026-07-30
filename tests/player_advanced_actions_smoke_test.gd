extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if (
		not InputMap.has_action(&"jump")
		or not InputMap.has_action(&"slide")
	):
		_fail("Jump or slide input mapping is missing.")
		return
	var player := (
		load("res://scenes/player/player.tscn") as PackedScene
	).instantiate() as CharacterBody2D
	root.add_child(player)
	await physics_frame

	var jump_count := [0]
	var slide_count := [0]
	player.jump_started.connect(
		func(_direction: Vector2) -> void: jump_count[0] += 1
	)
	player.slide_started.connect(
		func(_direction: Vector2) -> void: slide_count[0] += 1
	)
	var health := player.get_node("HealthComponent") as HealthComponent

	var start := player.global_position
	if not player.start_jump(Vector2.RIGHT):
		_fail("Jump could not start.")
		return
	await physics_frame
	if (
		jump_count[0] != 1
		or player.global_position.x <= start.x
		or player.jump_remaining <= 0.0
		or not health.is_invulnerable()
		or player.start_jump(Vector2.RIGHT)
	):
		_fail("Jump movement, cooldown, or invulnerability is invalid.")
		return

	player.jump_remaining = 0.0
	player.jump_cooldown_remaining = 0.0
	health.invulnerability_remaining = 0.0
	start = player.global_position
	if not player.start_slide(Vector2.DOWN):
		_fail("Slide could not start.")
		return
	await physics_frame
	if (
		slide_count[0] != 1
		or player.global_position.y <= start.y
		or player.slide_remaining <= 0.0
		or not health.is_invulnerable()
		or player.start_slide(Vector2.DOWN)
	):
		_fail("Slide movement, cooldown, or invulnerability is invalid.")
		return

	print("Player jump and slide smoke test passed.")
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
