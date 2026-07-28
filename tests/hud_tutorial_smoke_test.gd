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
	var health_bar := main.get_node(
		"Interface/PlayerVitals/Frame/HealthBar"
	) as ProgressBar
	var experience_bar := main.get_node(
		"Interface/PlayerVitals/Frame/ExperienceBar"
	) as ProgressBar
	var health_text := main.get_node(
		"Interface/PlayerVitals/Frame/HealthText"
	) as Label
	var experience_text := main.get_node(
		"Interface/PlayerVitals/Frame/ExperienceText"
	) as Label
	var tutorial := main.get_node(
		"TutorialOverlay"
	) as TutorialOverlay
	var minimap := main.get_node(
		"Interface/RunMinimap"
	) as RunMinimapPresenter
	var weapon_slots := main.get_node(
		"Interface/WeaponSlots"
	) as WeaponSlotsHud
	var area_intro := main.get_node(
		"Interface/AreaIntro"
	) as AreaIntroPresenter
	var essence_icon := main.get_node(
		"Interface/PlayerVitals/EssenceRow/Icon"
	) as TextureRect
	var essence_amount := main.get_node(
		"Interface/PlayerVitals/EssenceRow/Amount"
	) as Label

	if (
		bool(gene_harness.get("debug_hotkeys_enabled"))
		or bool(relic_harness.get("debug_hotkeys_enabled"))
		or debug_status.visible
		or not is_equal_approx(health_bar.value, 100.0)
		or not is_equal_approx(experience_bar.value, 0.0)
		or health_text.text != "100/100"
		or experience_text.text != "0/20"
		or minimap.size != Vector2(68.0, 64.0)
		or minimap.room_manager.current_room_index != 0
		or weapon_slots.active_slot != 0
		or weapon_slots.get_slot_organ(0) == null
		or not area_intro.visible
		or area_intro.title_label.text != "原生培养区"
		or area_intro.objective_label.text != "走进孵化仓"
		or essence_icon.texture == null
		or essence_amount.text != "× 0"
	):
		push_error("Release HUD or new run interface is invalid.")
		quit(1)
		return

	if not tutorial.is_tutorial_visible():
		push_error("First-run tutorial was not visible.")
		quit(1)
		return
	for icon_path in [
		"ControlHints/Content/Movement/Icon",
		"ControlHints/Content/Aim/Icon",
		"ControlHints/Content/Dash/Icon",
	]:
		var icon := tutorial.get_node(icon_path) as TextureRect
		if icon.texture == null:
			push_error("Control hint icon was not configured: " + icon_path)
			quit(1)
			return
	tutorial.dismiss()
	if tutorial.is_tutorial_visible():
		push_error("Tutorial overlay could not be dismissed.")
		quit(1)
		return

	var player := main.get_node("World/Player") as CharacterBody2D
	var progression := player.get_node("RunProgression") as RunProgression
	progression.add_essence(5)
	if essence_amount.text != "× 5":
		push_error("Gene essence HUD did not follow run progression.")
		quit(1)
		return
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
