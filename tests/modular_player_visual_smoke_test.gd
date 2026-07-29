extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := (
		load("res://scenes/player/player.tscn") as PackedScene
	).instantiate() as CharacterBody2D
	root.add_child(player)
	await physics_frame
	await process_frame

	var modular := player.get_node(
		"Visuals/ModularCharacterVisual"
	) as ModularCharacterVisual
	var pixel_presenter := player.get_node(
		"PixelActorPresenter"
	) as PixelActorPresenter
	if (
		not modular.visible
		or not modular.is_base_form
		or pixel_presenter.sprite.visible
		or not player.get_node("Visuals").visible
		or modular.part_sprites.size() < 18
	):
		push_error("Modular base-life visual did not activate.")
		quit(1)
		return

	player.velocity = Vector2.LEFT * 100.0
	modular._process(0.1)
	if modular.facing_sign != 1.0:
		push_error("Left-facing modular animation is invalid.")
		quit(1)
		return
	player.velocity = Vector2.UP * 100.0
	modular._process(0.1)
	if modular.facing_sign != 1.0:
		push_error("Vertical movement did not preserve facing.")
		quit(1)
		return
	player.velocity = Vector2.RIGHT * 100.0
	modular._process(0.1)
	if modular.facing_sign != -1.0:
		push_error("Right-facing modular animation is invalid.")
		quit(1)
		return

	var original_tail := modular.get_part_texture(&"tail")
	if (
		original_tail == null
		or not modular.set_part_texture(&"tail", original_tail)
		or modular.set_part_texture(&"unknown_part", original_tail)
	):
		push_error("Modular part replacement interface is invalid.")
		quit(1)
		return

	modular.play_action(&"attack", 0.28)
	modular._process(0.05)
	if modular.current_action != &"attack":
		push_error("Modular attack animation did not start.")
		quit(1)
		return

	var health := player.get_node("HealthComponent") as HealthComponent
	health.take_damage(10.0)
	await process_frame
	if modular.current_action != &"hurt":
		push_error("Modular hurt animation did not start.")
		quit(1)
		return
	health.invulnerability_remaining = 0.0
	health.take_damage(1000.0)
	await process_frame
	if not modular.is_dead or modular.current_action != &"death":
		push_error("Modular death animation did not start.")
		quit(1)
		return
	modular._process(0.6)
	if absf(modular.root_bone.rotation) < 1.0:
		push_error("Modular death pose did not progress.")
		quit(1)
		return

	print("Modular player visual smoke test passed.")
	quit()
