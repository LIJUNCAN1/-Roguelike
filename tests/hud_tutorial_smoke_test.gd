extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame
	await process_frame

	var gene_harness := main.get_node("GeneTestHarness")
	var relic_harness := main.get_node("RelicTestHarness")
	var debug_status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/Status"
	) as Label
	var health_status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/HealthStatus"
	) as Label
	var health_bar := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/HealthBar"
	) as ProgressBar
	var experience_status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/ExperienceStatus"
	) as Label
	var tutorial := main.get_node(
		"TutorialOverlay"
	) as TutorialOverlay

	if (
		bool(gene_harness.get("debug_hotkeys_enabled"))
		or bool(relic_harness.get("debug_hotkeys_enabled"))
		or debug_status.visible
		or health_status.text.contains("测试")
		or not is_equal_approx(health_bar.value, 100.0)
		or not experience_status.text.contains("Lv.1")
	):
		push_error("Release HUD still exposed developer controls.")
		quit(1)
		return

	if not tutorial.is_tutorial_visible():
		push_error("First-run tutorial was not visible.")
		quit(1)
		return
	tutorial.dismiss()
	if tutorial.is_tutorial_visible():
		push_error("Tutorial overlay could not be dismissed.")
		quit(1)
		return

	var player := main.get_node("World/Player") as CharacterBody2D
	var gene_manager := player.get_node("GeneManager") as GeneManager
	var gene_status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/GeneStatus"
	) as Label
	gene_manager.add_gene(
		load("res://data/genes/fire_gene.tres") as GeneData
	)
	if not gene_status.text.contains("火焰基因"):
		push_error("Release build presenter did not update the HUD.")
		quit(1)
		return

	print("HUD and tutorial smoke test passed.")
	quit()
