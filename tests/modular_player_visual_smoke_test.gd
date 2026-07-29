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
		or modular.part_sprites.size() < 23
		or modular.get_node_or_null("PoseSprite") != null
	):
		push_error("Modular base-life visual did not activate.")
		quit(1)
		return

	player.velocity = Vector2.LEFT * 100.0
	var walk_rotation_min := INF
	var walk_rotation_max := -INF
	for frame in 12:
		modular._process(1.0 / 60.0)
		walk_rotation_min = minf(
			walk_rotation_min,
			modular.leg_front_bone.rotation
		)
		walk_rotation_max = maxf(
			walk_rotation_max,
			modular.leg_front_bone.rotation
		)
		if (
			modular.root_bone.position != Vector2.ZERO
			or modular.rig.position != Vector2.ZERO
		):
			push_error("Moving modular rig introduced root jitter.")
			quit(1)
			return
	if (
		modular.facing_sign != 1.0
		or not modular.rig.visible
		or walk_rotation_max - walk_rotation_min < 0.1
	):
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
	if (
		modular.facing_sign != -1.0
		or modular.rig.scale.x >= 0.0
	):
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

	var weapon_front := modular.part_sprites.get(
		&"weapon_front"
	) as Sprite2D
	var weapon_back := modular.part_sprites.get(
		&"weapon_back"
	) as Sprite2D
	if (
		weapon_front == null
		or weapon_back == null
		or weapon_front.texture == null
		or weapon_back.texture == null
		or not weapon_front.visible
		or not weapon_back.visible
		or weapon_front.z_index
		!= ModularCharacterVisual.REFERENCE_DRAW_LAYERS[&"weapon_front"]
		or weapon_back.z_index
		!= ModularCharacterVisual.REFERENCE_DRAW_LAYERS[&"weapon_back"]
		or weapon_front.scale.x >= 0.8
		or weapon_back.scale.x >= 0.8
	):
		push_error("Modular twin-blade parts are not calibrated.")
		quit(1)
		return

	var foot_front := modular.part_sprites.get(
		&"foot_front"
	) as Sprite2D
	var foot_bottom := foot_front.to_global(
		Vector2(0.0, foot_front.texture.get_height() * 0.5)
	).y
	if absf(foot_bottom - player.global_position.y) > 1.0:
		push_error("Modular feet are not aligned with the actor ground.")
		quit(1)
		return
	var shadow := player.get_node("Visuals/Shadow") as Polygon2D
	if absf(shadow.global_position.y - player.global_position.y) > 2.0:
		push_error("Player shadow is not aligned with the actor ground.")
		quit(1)
		return

	modular.play_action(&"attack", 0.28)
	modular._process(0.05)
	if (
		modular.current_action != &"attack"
		or modular.arm_front_bone.rotation
		== modular.rest_rotations[modular.arm_front_bone]
	):
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
	if modular.root_bone.rotation >= -0.1:
		push_error("Modular death pose did not progress.")
		quit(1)
		return

	print("Modular player visual smoke test passed.")
	quit()
