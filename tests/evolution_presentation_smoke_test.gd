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
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var health := player.get_node("HealthComponent") as HealthComponent
	var aura := player.get_node(
		"EvolutionAuraPresenter"
	) as EvolutionAuraPresenter
	var flash := main.get_node(
		"Interface/EvolutionFlash"
	) as ColorRect
	var banner := main.get_node(
		"Interface/EvolutionBanner"
	) as Label
	var effects := main.get_node("World/Effects") as Node2D
	var visuals := player.get_node("Visuals") as Node2D

	gene_manager.add_gene(
		load("res://data/genes/fire_gene.tres") as GeneData
	)
	await process_frame
	if (
		not flash.visible
		or not banner.visible
		or not banner.text.contains("原始生命")
		or not banner.text.contains("火焰生命")
		or not banner.text.contains("攻击")
		or not health.is_invulnerable()
		or effects.get_node_or_null("EvolutionBurst") == null
		or visuals.scale.is_equal_approx(Vector2.ONE)
		or aura.presentation_data == null
		or not aura.presentation_data.accent_color.is_equal_approx(
			Color(1, 0.32, 0.08, 1)
		)
	):
		push_error("Evolution presentation feedback is incomplete.")
		quit(1)
		return

	var projectile_data := ProjectileData.new()
	projectile_data.damage = 10.0
	var attack := AttackContext.new(
		null,
		projectile_data,
		Vector2.RIGHT
	)
	player.get_node("EvolutionSystem").modify_attack(attack)
	if not attack.has_tag(&"fire_life_form"):
		push_error("Evolution did not retain its attack transformation.")
		quit(1)
		return

	await create_timer(2.0).timeout
	if banner.visible or flash.visible:
		push_error("Evolution presentation UI did not clean itself up.")
		quit(1)
		return

	print("Evolution presentation smoke test passed.")
	quit()
