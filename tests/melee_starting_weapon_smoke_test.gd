extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := (
		load("res://scenes/player/player.tscn") as PackedScene
	).instantiate() as CharacterBody2D
	var projectile_container := Node2D.new()
	projectile_container.name = "ProjectileContainer"
	root.add_child(projectile_container)
	player.projectile_container_path = projectile_container.get_path()
	root.add_child(player)
	await physics_frame
	await process_frame

	var organ_manager := player.get_node(
		"WeaponOrganManager"
	) as WeaponOrganManager
	if (
		organ_manager.current_organ == null
		or organ_manager.current_organ.id != &"twin_blade_organ"
		or organ_manager.current_organ.display_name != "原生双刃"
		or organ_manager.current_organ.weapon_data == null
		or organ_manager.current_organ.weapon_data.attack_cue == null
		or organ_manager.current_organ.weapon_data.impact_cue == null
	):
		push_error("Player melee organ or its audio cues are invalid.")
		quit(1)
		return

	player.aim_at(player.global_position + Vector2.RIGHT * 100.0)
	var slash := player.fire() as Projectile
	if (
		slash == null
		or slash.projectile_data.speed != 0.0
		or slash.projectile_data.lifetime > 0.2
		or slash.projectile_data.radius < 16.0
	):
		push_error("Starting melee slash was not configured correctly.")
		quit(1)
		return

	print("Melee starting weapon smoke test passed.")
	quit()
