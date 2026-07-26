extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var enemy := (
		load("res://scenes/enemies/test_chaser.tscn") as PackedScene
	).instantiate() as EnemyController
	root.add_child(enemy)
	await process_frame

	var venom := load(
		"res://data/genes/impact_effects/venom_effect.tres"
	) as DamageOverTimeImpactEffect
	var frost := load(
		"res://data/genes/impact_effects/frost_effect.tres"
	) as SlowImpactEffect
	var hurtbox := enemy.get_node(
		"HurtboxComponent"
	) as HurtboxComponent
	var impact := ImpactContext.new(
		null,
		null,
		hurtbox,
		enemy.global_position,
		1.0
	)
	var health_before := enemy.health_component.current_health
	venom.apply(impact)
	frost.apply(impact)
	if not is_equal_approx(
		enemy.movement_component.move_speed,
		enemy.enemy_data.move_speed * frost.speed_multiplier
	):
		push_error("Frost gene did not slow the enemy.")
		quit(1)
		return

	for _frame in 105:
		await physics_frame
	if not is_equal_approx(
		enemy.health_component.current_health,
		health_before - venom.tick_damage * venom.tick_count
	):
		push_error("Venom gene did not apply all damage ticks.")
		quit(1)
		return

	for _frame in 20:
		await physics_frame
	if not is_equal_approx(
		enemy.movement_component.move_speed,
		enemy.enemy_data.move_speed
	):
		push_error("Frost slow did not restore movement speed.")
		quit(1)
		return

	print("Status gene effects smoke test passed.")
	quit()
