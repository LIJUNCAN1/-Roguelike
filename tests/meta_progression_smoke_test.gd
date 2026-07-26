extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var meta := root.get_node(
		"/root/MetaProgression"
	) as MetaProgressionManager
	meta.reset_profile(false)
	if meta.catalog == null or meta.catalog.upgrades.size() != 6:
		push_error("Meta upgrade catalog is incomplete.")
		quit(1)
		return
	meta.currency = 100
	if (
		not meta.purchase_upgrade(&"vitality")
		or not meta.purchase_upgrade(&"ferocity")
		or not meta.purchase_upgrade(&"precision")
		or not meta.purchase_upgrade(&"resilience")
	):
		push_error("Meta upgrades could not be purchased.")
		meta.reset_profile(false)
		quit(1)
		return

	var player := (
		load("res://scenes/player/player.tscn") as PackedScene
	).instantiate() as CharacterBody2D
	root.add_child(player)
	await process_frame
	await process_frame
	var health := player.get_node("HealthComponent") as HealthComponent
	if (
		not is_equal_approx(health.max_health, 110.0)
		or not is_equal_approx(health.damage_taken_multiplier, 0.97)
	):
		push_error("Meta survival upgrades were not applied to a new run.")
		meta.reset_profile(false)
		quit(1)
		return
	var projectile_data := ProjectileData.new()
	projectile_data.damage = 10.0
	var attack := AttackContext.new(
		null,
		projectile_data,
		Vector2.RIGHT
	)
	player.get_node("AttackModifierStack").modify_attack(attack)
	if (
		not attack.has_tag(&"meta_evolution")
		or not is_equal_approx(attack.projectile_data.damage, 10.5)
		or not is_equal_approx(
			attack.projectile_data.critical_chance,
			0.03
		)
	):
		push_error("Meta attack upgrades were not applied.")
		meta.reset_profile(false)
		quit(1)
		return

	var isolated := MetaProgressionManager.new()
	isolated.save_path = "user://meta_progression_smoke_test.json"
	root.add_child(isolated)
	await process_frame
	isolated.reset_profile(false)
	isolated.currency = 42
	isolated.upgrade_levels["vitality"] = 2
	if not isolated.save_profile():
		push_error("Meta profile could not be saved.")
		meta.reset_profile(false)
		quit(1)
		return
	var loaded := MetaProgressionManager.new()
	loaded.save_path = isolated.save_path
	root.add_child(loaded)
	await process_frame
	if (
		not loaded.load_profile()
		or loaded.currency != 42
		or loaded.get_upgrade_level(&"vitality") != 2
	):
		push_error("Meta profile could not be loaded.")
		meta.reset_profile(false)
		quit(1)
		return

	meta.reset_profile(false)
	print("Meta progression smoke test passed.")
	quit()
