extends SceneTree

const EXPECTED_INTERACTIONS := {
	&"core_altar": Vector2(800, 294),
	&"bloodline_shop": Vector2(320, 282),
	&"forge_station": Vector2(260, 562),
	&"archive_station": Vector2(1280, 294),
	&"rest_campfire": Vector2(1320, 628),
	&"companion_station": Vector2(380, 846),
}


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1280, 720)
	if not InputMap.has_action(&"interact"):
		_fail("Interact input action is missing.")
		return
	var packed := load(
		"res://scenes/hub/hub_world.tscn"
	) as PackedScene
	if packed == null:
		_fail("Hub scene could not be loaded.")
		return
	var hub := packed.instantiate() as HubWorld
	hub.scene_transitions_enabled = false
	hub.facility_panels_enabled = false
	root.add_child(hub)
	current_scene = hub
	await physics_frame
	await process_frame

	var player := hub.player
	var spawn := hub.player_spawn.global_position
	if (
		player == null
		or not player.is_inside_tree()
		or not player.global_position.is_equal_approx(spawn)
		or spawn != Vector2(800, 650)
	):
		_fail("Hub player did not spawn at the configured marker.")
		return

	if (
		hub.reference_layer.visible
		or hub.reference_image.texture == null
		or hub.reference_image.texture.get_size()
		!= Vector2(1568, 1003)
	):
		_fail("Hidden hub reference layer is invalid.")
		return

	var y_sort_root := hub.get_node("YSortRoot") as Node2D
	var stations := hub.get_node("YSortRoot/Stations") as Node2D
	if (
		not y_sort_root.y_sort_enabled
		or not stations.y_sort_enabled
		or player.get_parent() != y_sort_root
	):
		_fail("Hub Y sorting hierarchy is invalid.")
		return

	if (
		hub.camera.limit_left != 0
		or hub.camera.limit_top != 0
		or hub.camera.limit_right != 1600
		or hub.camera.limit_bottom != 1000
		or hub.camera.zoom != Vector2(2, 2)
		or not hub.camera.enabled
	):
		_fail("Hub camera limits are invalid.")
		return
	var static_collisions := hub.get_node(
		"StaticEnvironment/StaticCollisions"
	)
	if static_collisions.get_child_count() < 9:
		_fail("Required hub obstacle collisions are missing.")
		return

	var start_x := player.global_position.x
	Input.action_press("move_right")
	for _frame in 12:
		await physics_frame
	Input.action_release("move_right")
	if player.global_position.x <= start_x + 4.0:
		_fail("Player input movement did not work in the hub.")
		return

	player.global_position = Vector2(55, 500)
	Input.action_press("move_left")
	for _frame in 30:
		await physics_frame
	Input.action_release("move_left")
	if player.global_position.x < 46.0:
		_fail("Player escaped through the west world boundary.")
		return

	player.global_position = Vector2(800, 330)
	Input.action_press("move_up")
	for _frame in 45:
		await physics_frame
	Input.action_release("move_up")
	if player.global_position.y < 269.0:
		_fail("Player crossed the core altar collision.")
		return

	var interactables: Array[Interactable] = []
	for node in get_nodes_in_group(&"hub_interactables"):
		if hub.is_ancestor_of(node) and node is Interactable:
			interactables.append(node as Interactable)
	if interactables.size() != EXPECTED_INTERACTIONS.size():
		_fail("Hub does not contain exactly six interactables.")
		return

	var event := InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	for interactable in interactables:
		if not EXPECTED_INTERACTIONS.has(interactable.interaction_id):
			_fail(
				"Unexpected hub interaction: %s"
				% interactable.interaction_id
			)
			return
		if (
			not interactable.global_position.is_equal_approx(
				EXPECTED_INTERACTIONS[interactable.interaction_id]
			)
		):
			_fail(
				"Hub interaction coordinate is incorrect: %s"
				% interactable.interaction_id
			)
			return
		interactable._on_body_entered(player)
		await process_frame
		if (
			not hub.interaction_prompt.visible
			or not hub.interaction_prompt.prompt_label.text.contains(
				interactable.display_name
			)
		):
			_fail("Interaction prompt did not show the facility name.")
			return
		interactable._unhandled_input(event)
		await process_frame
		if hub.last_interaction_id != interactable.interaction_id:
			_fail(
				"Interaction did not trigger: %s"
				% interactable.interaction_id
			)
			return
		interactable._on_body_exited(player)
		await process_frame

	hub.facility_panels_enabled = true
	var bloodline := _find_interactable(
		interactables,
		&"bloodline_shop"
	)
	hub._on_interaction_requested(&"bloodline_shop", bloodline)
	if not hub.meta_upgrade_dimmer.visible or not paused:
		_fail("Bloodline upgrade facility did not open.")
		return
	hub._close_facility_panels()
	var archive := _find_interactable(
		interactables,
		&"archive_station"
	)
	hub._on_interaction_requested(&"archive_station", archive)
	if not hub.codex_dimmer.visible or not paused:
		_fail("Hub codex facility did not open.")
		return
	hub._close_facility_panels()

	var health_bar := player.get_node(
		"HealthComponent"
	) as HealthComponent
	if (
		health_bar == null
		or not is_equal_approx(health_bar.current_health, 100.0)
		or hub.interaction_prompt == null
	):
		_fail("Player state or hub HUD was damaged.")
		return

	print("Hub world smoke test passed.")
	quit()


func _find_interactable(
	interactables: Array[Interactable],
	interaction_id: StringName
) -> Interactable:
	for interactable in interactables:
		if interactable.interaction_id == interaction_id:
			return interactable
	return null


func _fail(message: String) -> void:
	paused = false
	Input.action_release("move_up")
	Input.action_release("move_down")
	Input.action_release("move_left")
	Input.action_release("move_right")
	push_error(message)
	quit(1)
