extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := (
		load("res://scenes/main/main.tscn") as PackedScene
	).instantiate()
	root.add_child(main)
	await process_frame

	var player := main.get_node("World/Player") as CharacterBody2D
	var genes := player.get_node("GeneManager") as GeneManager
	var codex := main.get_node(
		"GeneCodexManager"
	) as GeneCodexManager
	var panel := main.get_node("GeneCodexPanel") as GeneCodexPanel
	var notification := main.get_node(
		"Interface/BuildNotification"
	) as Label
	var explosion := load(
		"res://data/genes/explosion_gene.tres"
	) as GeneData
	var fire := load("res://data/genes/fire_gene.tres") as GeneData

	genes.add_gene(explosion)
	genes.add_gene(fire)
	await process_frame
	if (
		not codex.is_gene_seen(explosion.id)
		or not codex.is_gene_seen(fire.id)
	):
		push_error("Obtained genes were not recorded in the codex.")
		quit(1)
		return
	if (
		explosion.series_id != fire.series_id
		or not notification.text.contains(explosion.display_name)
		or not notification.text.contains("已有关联")
	):
		push_error(
			"New gene notification did not show owned series links: %s"
			% notification.text
		)
		quit(1)
		return

	panel.open()
	if (
		not panel.is_open()
		or not paused
		or not panel.entries.text.contains(fire.description)
		or not panel.entries.text.contains(fire.get_rarity_name())
		or not panel.entries.text.contains(fire.get_category_name())
		or not panel.entries.text.contains("#fire")
	):
		push_error("Gene codex did not show unlocked descriptions.")
		quit(1)
		return
	panel.close()
	if panel.is_open() or paused:
		push_error("Gene codex did not restore the previous pause state.")
		quit(1)
		return

	print("Gene codex smoke test passed.")
	quit()
