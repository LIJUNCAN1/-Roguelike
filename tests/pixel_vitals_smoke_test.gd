extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := (
		load("res://scenes/main/main.tscn") as PackedScene
	).instantiate()
	root.add_child(main)
	await process_frame
	var vitals := main.get_node(
		"Interface/PlayerVitals"
	) as PixelVitalsPresenter
	var health := main.get_node(
		"World/Player/HealthComponent"
	) as HealthComponent
	var progression := main.get_node(
		"World/Player/RunProgression"
	) as RunProgression
	var level_text := main.get_node(
		"Interface/PlayerVitals/Frame/LevelText"
	) as Label
	var full_health_color := (
		vitals.health_bar as FramedVitalBar
	).fill_color
	health.invulnerability_remaining = 0.0
	health.take_damage(37.0)
	progression.add_experience(9)
	await process_frame
	var damaged_health_color := (
		vitals.health_bar as FramedVitalBar
	).fill_color
	if (
		vitals.health_text.text != "63/100"
		or not is_equal_approx(vitals.health_bar.value, 63.0)
		or vitals.experience_text.text != "9/20"
		or vitals.experience_text.visible
		or not is_equal_approx(vitals.experience_bar.value, 9.0)
		or vitals.size != Vector2(276.0, 68.0)
		or vitals.position != Vector2(20.0, 16.0)
		or vitals.scale != Vector2.ONE
		or main.has_node(
			"Interface/PlayerVitals/Frame/PortraitComponent"
		)
		or not vitals.health_bar is FramedVitalBar
		or not vitals.experience_bar is FramedVitalBar
		or (
			vitals.health_bar as FramedVitalBar
		).frame_texture == null
		or (
			vitals.experience_bar as FramedVitalBar
		).frame_texture == null
		or (
			vitals.health_bar as FramedVitalBar
		).fill_texture == null
		or (
			vitals.health_bar as FramedVitalBar
		).empty_texture == null
		or (
			vitals.experience_bar as FramedVitalBar
		).fill_texture == null
		or (
			vitals.experience_bar as FramedVitalBar
		).empty_texture == null
		or vitals.get_node("CoinRow").position.y != 40.0
		or level_text.text != "Lv.1"
		or damaged_health_color.get_luminance()
		<= full_health_color.get_luminance()
	):
		push_error("Pixel vitals did not match the reference behavior.")
		quit(1)
		return
	print("Pixel vitals smoke test passed.")
	quit()
