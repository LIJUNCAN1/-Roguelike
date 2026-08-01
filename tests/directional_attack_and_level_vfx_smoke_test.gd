extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := (
		load("res://scenes/main/main.tscn") as PackedScene
	).instantiate()
	root.add_child(main)
	await physics_frame
	await process_frame
	var player := main.get_node("World/Player") as CharacterBody2D
	var projectiles := main.get_node("World/Projectiles") as Node2D
	Input.action_press("attack_right")
	await physics_frame
	await physics_frame
	var attack_strength := Input.get_action_strength("attack_right")
	Input.action_release("attack_right")
	await process_frame
	if (
		player.get_facing_direction().x < 0.9
		or projectiles.get_child_count() == 0
	):
		_fail("Arrow-direction attack failed: facing=%s projectiles=%d input=%s" % [
			player.get_facing_direction(),
			projectiles.get_child_count(),
			attack_strength,
		])
		return
	var frame_visual := player.get_node(
		"Visuals/ModularCharacterVisual"
	) as FrameCharacterVisual
	if (
		frame_visual.current_action == &"attack"
		or frame_visual.attack_slash.visible
		or not is_zero_approx(frame_visual.pose_root.rotation)
	):
		_fail("Slime ranged attack still uses lean or slash feedback.")
		return
	var progression := player.get_node("RunProgression") as RunProgression
	var level_vfx := player.get_node("LevelUpVfx/Sprite") as AnimatedSprite2D
	progression.add_experience(20)
	await process_frame
	if progression.level != 2 or not level_vfx.visible or not level_vfx.is_playing():
		_fail("Holy level-up VFX did not play over the player.")
		return
	print("Directional attack and level VFX smoke test passed.")
	quit()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
