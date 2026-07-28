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
	var portrait := main.get_node(
		"Interface/PlayerVitals/Frame/PortraitComponent/Portrait"
	) as TextureRect
	var portrait_fade := main.get_node(
		"Interface/PlayerVitals/Frame/PortraitComponent/Fade"
	) as TextureRect
	var portrait_component := main.get_node(
		"Interface/PlayerVitals/Frame/PortraitComponent"
	) as VitalsPortrait
	var level_text := main.get_node(
		"Interface/PlayerVitals/Frame/LevelText"
	) as Label
	var full_health_color := (
		vitals.health_bar.get_theme_stylebox("fill") as StyleBoxFlat
	).bg_color
	var empty_experience_color := (
		vitals.experience_bar.get_theme_stylebox("fill") as StyleBoxFlat
	).bg_color
	health.invulnerability_remaining = 0.0
	health.take_damage(37.0)
	progression.add_experience(9)
	await process_frame
	var damaged_health_color := (
		vitals.health_bar.get_theme_stylebox("fill") as StyleBoxFlat
	).bg_color
	var gained_experience_color := (
		vitals.experience_bar.get_theme_stylebox("fill") as StyleBoxFlat
	).bg_color
	if (
		vitals.health_text.text != "63/100"
		or not is_equal_approx(vitals.health_bar.value, 63.0)
		or vitals.experience_text.text != ""
		or vitals.experience_text.visible
		or not is_equal_approx(vitals.experience_bar.value, 9.0)
		or vitals.size != Vector2(256.0, 112.0)
		or vitals.position != Vector2(16.0, 16.0)
		or portrait.texture == null
		or portrait_fade.texture == null
		or portrait_component.portrait_texture == null
		or not vitals.health_bar is AngularVitalBar
		or not vitals.experience_bar is AngularVitalBar
		or (
			vitals.health_bar as AngularVitalBar
		).frame_texture == null
		or (
			vitals.experience_bar as AngularVitalBar
		).frame_texture == null
		or (
			vitals.health_bar as AngularVitalBar
		).pattern_texture == null
		or vitals.experience_bar.position.x <= level_text.position.x
		or vitals.get_node("EssenceRow").position.y < 80.0
		or level_text.text != "Lv.1"
		or damaged_health_color.get_luminance()
		<= full_health_color.get_luminance()
		or gained_experience_color.get_luminance()
		<= empty_experience_color.get_luminance()
	):
		push_error("Pixel vitals did not match the reference behavior.")
		quit(1)
		return
	print("Pixel vitals smoke test passed.")
	quit()
