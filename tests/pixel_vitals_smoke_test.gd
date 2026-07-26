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
	health.invulnerability_remaining = 0.0
	health.take_damage(37.0)
	progression.add_experience(9)
	await process_frame
	if (
		vitals.health_text.text != "63/100"
		or not is_equal_approx(vitals.health_bar.value, 63.0)
		or vitals.experience_text.text != "9/20"
		or not is_equal_approx(vitals.experience_bar.value, 9.0)
		or vitals.size != Vector2(326.0, 66.0)
	):
		push_error("Pixel vitals did not match the reference behavior.")
		quit(1)
		return
	print("Pixel vitals smoke test passed.")
	quit()
