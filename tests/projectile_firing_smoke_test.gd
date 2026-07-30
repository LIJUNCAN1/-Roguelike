extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame

	var player := main.get_node("World/Player") as CharacterBody2D
	var projectile_container := main.get_node("World/Projectiles") as Node2D
	var weapon_component := player.get_node(
		"WeaponComponent"
	) as WeaponComponent
	if not weapon_component.set_weapon_data(
		load("res://data/weapons/basic_weapon.tres") as WeaponData
	):
		push_error("Test ranged weapon could not be equipped.")
		quit(1)
		return
	player.aim_at(player.global_position + Vector2.RIGHT * 100.0)

	var projectile: Node2D = player.fire() as Node2D
	if projectile == null:
		push_error("Player did not create a projectile.")
		quit(1)
		return

	if projectile.get_parent() != projectile_container:
		push_error("Projectile was added to the wrong container.")
		quit(1)
		return

	var spawn_position: Vector2 = projectile.global_position
	if player.fire() != null:
		push_error("Weapon cooldown did not prevent immediate refiring.")
		quit(1)
		return

	await physics_frame
	await physics_frame
	if projectile.global_position.x <= spawn_position.x:
		push_error("Projectile did not travel in the aim direction.")
		quit(1)
		return

	print("Projectile firing smoke test passed.")
	quit()
