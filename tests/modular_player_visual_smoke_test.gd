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

	var visual := player.get_node(
		"Visuals/ModularCharacterVisual"
	) as FrameCharacterVisual
	var pixel_presenter := player.get_node(
		"PixelActorPresenter"
	) as PixelActorPresenter
	if (
		not visual.visible
		or not visual.is_base_form
		or pixel_presenter.sprite.visible
		or not player.get_node("Visuals").visible
		or visual.get_animation_frame_count(&"idle") != 8
		or visual.get_animation_frame_count(&"run_start") != 4
		or visual.get_animation_frame_count(&"run_loop") != 8
		or visual.get_animation_frame_count(&"run_stop") != 4
		or visual.get_animation_frame_count(&"run_side") != 16
		or visual.get_animation_frame_count(&"run_up") != 8
		or visual.get_animation_frame_count(&"run_down") != 8
		or visual.get_animation_frame_count(&"jump") != 16
		or visual.get_animation_frame_count(&"slide") != 8
		or visual.get_animation_frame_count(&"dodge") != 8
		or visual.get_animation_frame_count(&"hurt") != 16
		or visual.get_animation_frame_count(&"heal") != 8
		or visual.get_animation_frame_count(&"knockdown") != 16
		or visual.get_node_or_null("Rig") != null
	):
		push_error("Preview-GIF player visual did not activate.")
		quit(1)
		return

	var authored_ground := (
		visual.sprite.position.y
		+ FrameCharacterVisual.GROUND_ANCHOR_Y
		- FrameCharacterVisual.FRAME_SIZE.y * 0.5
	)
	if absf(authored_ground) > 0.01:
		push_error("GIF frames are not aligned to the actor ground.")
		quit(1)
		return

	player.velocity = Vector2.LEFT * 100.0
	visual._process(1.0 / 60.0)
	if (
		visual.facing_sign != 1.0
		or visual.sprite.flip_h
		or visual.sprite.animation != &"run_side"
	):
		push_error("Left-facing side-run animation is invalid.")
		quit(1)
		return
	player.velocity = Vector2.UP * 100.0
	visual._process(0.1)
	if visual.sprite.animation != &"run_up" or visual.sprite.flip_h:
		push_error("Up-facing run animation is invalid.")
		quit(1)
		return

	player.velocity = Vector2.DOWN * 100.0
	visual._process(0.1)
	if visual.sprite.animation != &"run_down" or visual.sprite.flip_h:
		push_error("Down-facing run animation is invalid.")
		quit(1)
		return
	player.velocity = Vector2.RIGHT * 100.0
	visual._process(0.1)
	if visual.facing_sign != -1.0 or not visual.sprite.flip_h:
		push_error("Right-facing horizontal flip is invalid.")
		quit(1)
		return

	visual.play_action(&"attack", 0.28)
	visual._process(0.14)
	if (
		visual.current_action != &"attack"
		or not visual.attack_slash.visible
		or visual.pose_root.position.is_zero_approx()
	):
		push_error("Attack animation did not start.")
		quit(1)
		return

	visual.play_action(&"dash", 0.34)
	visual._process(0.1)
	if (
		visual.current_action != &"dash"
		or visual.sprite.animation != &"dodge"
		or visual.ghost_near.visible
		or visual.sprite.speed_scale <= 1.0
	):
		push_error("GIF dodge animation did not start.")
		quit(1)
		return

	visual.current_action = &""
	visual.play_action(&"jump", 0.52)
	visual._process(0.1)
	if (
		visual.current_action != &"jump"
		or visual.sprite.animation != &"jump"
		or visual.sprite.speed_scale <= 1.0
	):
		push_error("GIF jump animation did not start.")
		quit(1)
		return

	visual.current_action = &""
	visual.play_action(&"slide", 0.34)
	visual._process(0.1)
	if (
		visual.current_action != &"slide"
		or visual.sprite.animation != &"slide"
		or visual.sprite.speed_scale <= 1.0
	):
		push_error("GIF slide animation did not start.")
		quit(1)
		return

	visual.current_action = &""
	var health := player.get_node("HealthComponent") as HealthComponent
	health.take_damage(10.0)
	await process_frame
	visual._process(0.1)
	if (
		visual.current_action != &"hurt"
		or visual.sprite.animation != &"hurt"
	):
		push_error("GIF hurt animation did not start.")
		quit(1)
		return

	visual.current_action = &""
	health.heal(5.0)
	await process_frame
	visual._process(0.1)
	if (
		visual.current_action != &"heal"
		or visual.sprite.animation != &"heal"
	):
		push_error("GIF heal animation did not start.")
		quit(1)
		return

	visual.current_action = &""
	health.invulnerability_remaining = 0.0
	health.take_damage(1000.0)
	await process_frame
	if (
		not visual.is_dead
		or visual.current_action != &"death"
		or visual.sprite.animation != &"knockdown"
	):
		push_error("GIF knockdown/death animation did not start.")
		quit(1)
		return

	var shadow := player.get_node("Visuals/Shadow") as Polygon2D
	if absf(shadow.global_position.y - player.global_position.y) > 2.0:
		push_error("Player shadow is not aligned with the actor ground.")
		quit(1)
		return

	print("Preview-GIF player visual smoke test passed.")
	quit()
