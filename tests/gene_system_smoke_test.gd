extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var fire_gene := load(
		"res://data/genes/fire_gene.tres"
	) as GeneData
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame

	var player := main.get_node("World/Player") as CharacterBody2D
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var weapon_component := (
		player.get_node("WeaponComponent") as WeaponComponent
	)
	var gene_status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/GeneStatus"
	) as Label

	player.aim_at(player.global_position + Vector2.UP * 100.0)
	var base_projectile := player.fire() as Projectile
	if base_projectile == null:
		push_error("Base projectile was not created.")
		quit(1)
		return

	if not is_equal_approx(base_projectile.projectile_data.damage, 10.0):
		push_error("Base projectile damage changed before adding a gene.")
		quit(1)
		return

	for _frame_index in 15:
		await physics_frame

	if not gene_manager.add_gene(fire_gene):
		push_error("Fire gene could not be added.")
		quit(1)
		return

	player.aim_at(player.global_position + Vector2.UP * 100.0)
	var fire_projectile := player.fire() as Projectile
	if fire_projectile == null:
		push_error("Fire projectile was not created.")
		quit(1)
		return

	if not is_equal_approx(fire_projectile.projectile_data.damage, 15.0):
		push_error("Fire gene did not modify projectile damage.")
		quit(1)
		return

	if not fire_projectile.attack_tags.has(&"fire"):
		push_error("Fire gene did not add its attack tag.")
		quit(1)
		return

	if fire_projectile.projectile_data.color != Color(1, 0.32, 0.08, 1):
		push_error("Fire gene did not change projectile color.")
		quit(1)
		return

	if not gene_status.text.contains("火焰"):
		push_error("Gene status UI did not react to the manager signal.")
		quit(1)
		return

	if not is_equal_approx(
		weapon_component.weapon_data.projectile_data.damage,
		10.0
	):
		push_error("Gene effect mutated the base weapon data.")
		quit(1)
		return

	if not gene_manager.remove_gene(&"fire"):
		push_error("Fire gene could not be removed.")
		quit(1)
		return

	if not gene_status.text.contains("无"):
		push_error("Gene status UI did not show the removed state.")
		quit(1)
		return

	print("Gene system smoke test passed.")
	quit()
