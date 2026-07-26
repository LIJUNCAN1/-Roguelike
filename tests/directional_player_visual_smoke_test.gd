extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := (
		load("res://scenes/main/main.tscn") as PackedScene
	).instantiate()
	root.add_child(main)
	await physics_frame

	var player := main.get_node("World/Player") as CharacterBody2D
	var presenter := player.get_node(
		"PixelActorPresenter"
	) as PixelActorPresenter
	presenter.set_process(false)

	if (
		presenter.visual_data == null
		or not presenter.visual_data.has_directional_frames()
		or presenter.visual_data.frame_regions.size() < 3
	):
		push_error("Little-life directional visual data was not loaded.")
		quit(1)
		return

	var checks := [
		[Vector2.DOWN, &"down", false, 0],
		[Vector2.UP, &"up", false, 1],
		[Vector2.RIGHT, &"side", false, 2],
		[Vector2.LEFT, &"side", true, 2],
	]
	for check in checks:
		player.aim_at(player.global_position + check[0] * 100.0)
		presenter._update_direction()
		presenter._apply_frame()
		var expected_region: Rect2 = (
			presenter.visual_data.frame_regions[check[3]]
		)
		if (
			presenter.current_direction != check[1]
			or presenter.sprite.flip_h != check[2]
			or presenter.sprite.region_rect != expected_region
		):
			push_error("Little-life direction mapping is invalid.")
			quit(1)
			return

	print("Directional player visual smoke test passed.")
	quit()
