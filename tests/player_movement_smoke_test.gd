extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame

	var player := main.get_node("World/Player") as CharacterBody2D
	var start_position := player.position

	Input.action_press("move_right")
	await physics_frame
	await physics_frame
	Input.action_release("move_right")

	if player.position.x <= start_position.x:
		push_error("Player did not move right.")
		quit(1)
		return

	if not player.get_facing_direction().is_equal_approx(Vector2.RIGHT):
		push_error("Player facing direction did not update.")
		quit(1)
		return

	await physics_frame
	if not player.velocity.is_zero_approx():
		push_error("Player did not stop after input was released.")
		quit(1)
		return

	print("Player movement smoke test passed.")
	quit()
