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
	var progression := player.get_node(
		"RunProgression"
	) as RunProgression
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var enemy := (
		load("res://scenes/enemies/test_chaser.tscn") as PackedScene
	).instantiate() as EnemyController
	main.get_node("World/RoomContainer").add_child(enemy)
	await process_frame

	var expected_experience := enemy.enemy_data.experience_reward
	var expected_coins := enemy.enemy_data.coin_reward
	var reward_source := Projectile.new()
	reward_source.source_actor = player
	enemy.health_component.take_damage(
		enemy.health_component.current_health,
		reward_source
	)
	reward_source.free()
	await process_frame
	if (
		progression.current_experience != expected_experience
		or progression.coins != expected_coins
	):
		push_error("Enemy defeat did not award progression currency.")
		quit(1)
		return

	progression.add_experience(100)
	var projectile_data := ProjectileData.new()
	projectile_data.damage = 10.0
	var context := AttackContext.new(
		null,
		projectile_data,
		Vector2.RIGHT
	)
	progression.modify_attack(context)
	if progression.level <= 1 or context.projectile_data.damage <= 10.0:
		push_error("Level growth did not increase attack damage.")
		quit(1)
		return

	var room_manager := main.get_node("RoomManager") as RoomManager
	room_manager.route_data.rooms[14] = load(
		"res://data/rooms/gene_shop_room.tres"
	) as RoomData
	if not room_manager.enter_room(14):
		push_error("Could not enter the physical gene shop.")
		quit(1)
		return
	await process_frame
	var shop := room_manager.current_room as GeneShopRoom
	if shop == null or shop.offers.size() != 2:
		push_error("Physical gene shop offers are invalid.")
		quit(1)
		return

	progression.add_coins(20)
	var coins_before := progression.coins
	var offer := shop.offers[0]
	if not shop.purchase_offer(0):
		push_error("Affordable shop offer could not be purchased.")
		quit(1)
		return
	if (
		not gene_manager.has_gene(offer.gene.id)
		or progression.coins != coins_before - offer.coin_cost
		or not shop.is_completed
	):
		push_error("Shop purchase did not update gene and coin state.")
		quit(1)
		return

	print("Progression and shop smoke test passed.")
	quit()
