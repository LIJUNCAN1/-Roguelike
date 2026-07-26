extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := main_scene.instantiate()
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

	if not room_manager.enter_room(2):
		push_error("Could not enter reward room.")
		quit(1)
		return
	await process_frame

	var reward_room := room_manager.current_room as GeneRewardRoom
	var offered := reward_room.get_offered_genes()
	if offered.size() != 3:
		push_error("Reward room did not offer three genes.")
		quit(1)
		return

	var offered_ids: Array[StringName] = []
	for gene in offered:
		if gene.id == &"fire" or gene.id in offered_ids:
			push_error("Reward choices contain an owned or duplicate gene.")
			quit(1)
			return
		offered_ids.append(gene.id)

	var gene_count_before := gene_manager.get_active_genes().size()
	var selected_gene := offered[1]
	if not reward_room.choose_gene(1):
		push_error("Valid gene reward could not be selected.")
		quit(1)
		return

	if (
		not reward_room.is_completed
		or not gene_manager.has_gene(selected_gene.id)
		or gene_manager.get_active_genes().size() != gene_count_before + 1
	):
		push_error("Selected reward was not applied exactly once.")
		quit(1)
		return

	if reward_room.choose_gene(0):
		push_error("Reward room accepted a second selection.")
		quit(1)
		return

	if not room_manager.advance_room():
		push_error("Could not leave completed reward room.")
		quit(1)
		return

	print("Gene reward smoke test passed.")
	quit()
