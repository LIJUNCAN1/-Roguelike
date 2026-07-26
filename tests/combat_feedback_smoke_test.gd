extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var projectile_scene := load(
		"res://scenes/combat/basic_projectile.tscn"
	) as PackedScene
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame

	var combat_room := TestRoomHelpers.enter_combat_room(main)
	var enemy := combat_room.get_node("TestChaser") as CharacterBody2D
	var health := enemy.get_node("HealthComponent") as HealthComponent
	var effects := main.get_node("World/Effects") as Node2D
	var visuals := enemy.get_node("Visuals") as Node2D
	var body_visual := enemy.get_node("Visuals/Body") as Polygon2D
	var source := projectile_scene.instantiate() as Projectile
	source.setup(Vector2.RIGHT)
	enemy.set_target(null)

	health.take_damage(10.0, source)
	if not effects.has_node("DamageNumber"):
		push_error("Damage number feedback was not created.")
		quit(1)
		return

	if visuals.position.x <= 0.0:
		push_error("Hit reaction did not offset the enemy visual.")
		quit(1)
		return

	if body_visual.color != Color.WHITE:
		push_error("Enemy did not flash white when damaged.")
		quit(1)
		return

	health.take_damage(20.0, source)
	if not effects.has_node("DeathEffect"):
		push_error("Death feedback was not created.")
		quit(1)
		return

	if not enemy.is_queued_for_deletion():
		push_error("Enemy did not queue deletion after death feedback.")
		quit(1)
		return

	source.free()
	print("Combat feedback smoke test passed.")
	quit()
