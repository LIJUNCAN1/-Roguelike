extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(640, 360)
	var main := (
		load("res://scenes/main/main.tscn") as PackedScene
	).instantiate()
	root.add_child(main)
	await physics_frame
	await process_frame

	var room_manager := main.get_node("RoomManager") as RoomManager
	var player := main.get_node("World/Player") as Node2D
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var fire_gene := load(
		"res://data/genes/fire_gene.tres"
	) as GeneData
	gene_manager.add_gene(fire_gene)
	room_manager.enter_room(3)
	await process_frame

	var reward_room := room_manager.current_room as GeneRewardRoom
	var panel := reward_room.get_node(
		"RewardInterface/RewardPanel"
	) as Control
	if (
		not reward_room.reward_interface.visible
		or panel.size.x > 640.0
		or panel.size.y > 360.0
		or reward_room.choice_buttons.size() != 3
	):
		push_error(
			(
				"Full-screen gene reward layout is invalid: visible=%s "
				+ "size=%s cards=%d"
			) % [
				reward_room.reward_interface.visible,
				panel.size,
				reward_room.choice_buttons.size(),
			]
		)
		quit(1)
		return

	for index in reward_room.choice_buttons.size():
		var card := reward_room.choice_buttons[index]
		var offered_gene := reward_room.offered_genes[index]
		if (
			card.gene_data != offered_gene
			or card.name_label.text != offered_gene.display_name
			or card.description_label.text != offered_gene.description
			or card.size.x < 180.0
			or card.size.y < 240.0
		):
			push_error("Gene reward card content or sizing is invalid.")
			quit(1)
			return

	var explosion_gene := load(
		"res://data/genes/explosion_gene.tres"
	) as GeneData
	var related: Array[GeneData] = [fire_gene]
	reward_room.choice_buttons[0].configure(
		explosion_gene,
		0,
		related
	)
	if not reward_room.choice_buttons[0].relation_label.text.contains(
		fire_gene.display_name
	):
		push_error("Gene card did not display owned same-series genes.")
		quit(1)
		return

	print("Gene reward interface smoke test passed.")
	quit()
