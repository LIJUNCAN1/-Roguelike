extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame

	var combat_room := TestRoomHelpers.enter_combat_room(main)
	var player := main.get_node("World/Player") as CharacterBody2D
	var enemy := combat_room.get_node("TestChaser") as CharacterBody2D
	var start_distance := enemy.global_position.distance_to(
		player.global_position
	)

	for frame_index in 5:
		await physics_frame

	var current_distance := enemy.global_position.distance_to(
		player.global_position
	)
	if current_distance >= start_distance:
		push_error("Enemy did not chase the player.")
		quit(1)
		return

	if enemy.get_facing_direction().x >= 0.0:
		push_error("Enemy did not face toward the player.")
		quit(1)
		return

	print("Enemy chase smoke test passed.")
	quit()
