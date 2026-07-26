extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := main_scene.instantiate()
	root.add_child(main)
	await physics_frame
	await process_frame

	var room_manager := main.get_node("RoomManager") as RoomManager
	var region_status := main.get_node(
		"Interface/StagePanel/MarginContainer/Labels/RegionStatus"
	) as Label
	var expected_regions: Array[StringName] = [
		&"primordial_culture",
		&"primordial_culture",
		&"primordial_culture",
		&"primordial_culture",
		&"primordial_culture",
		&"primordial_culture",
		&"abyss_lab",
		&"abyss_lab",
		&"abyss_lab",
		&"abyss_lab",
		&"abyss_lab",
		&"mechanical_hive",
		&"mechanical_hive",
		&"mechanical_hive",
		&"mechanical_hive",
		&"mechanical_hive",
	]
	for index in expected_regions.size():
		var room_data := room_manager.route_data.rooms[index]
		if (
			room_data.region == null
			or room_data.region.id != expected_regions[index]
		):
			push_error("Generated route did not span three regions.")
			quit(1)
			return

	if not _assert_current_region(
		room_manager,
		region_status,
		&"primordial_culture",
		"原生培养区"
	):
		quit(1)
		return

	if not room_manager.enter_room(6):
		push_error("Could not enter the abyss region.")
		quit(1)
		return
	await process_frame
	if not _assert_current_region(
		room_manager,
		region_status,
		&"abyss_lab",
		"深渊实验区"
	):
		quit(1)
		return

	if not room_manager.enter_room(11):
		push_error("Could not enter the mechanical region.")
		quit(1)
		return
	await process_frame
	if not _assert_current_region(
		room_manager,
		region_status,
		&"mechanical_hive",
		"机械铸巢区"
	):
		quit(1)
		return

	print("Region system smoke test passed.")
	quit()


func _assert_current_region(
	room_manager: RoomManager,
	region_status: Label,
	expected_id: StringName,
	expected_name: String
) -> bool:
	var room := room_manager.current_room
	var room_data := room_manager.get_current_room_data()
	if (
		room == null
		or room.current_region == null
		or room.current_region.id != expected_id
		or room_data.region != room.current_region
		or not region_status.text.contains(expected_name)
	):
		push_error("Current room did not apply its region data.")
		return false

	var shell := room.get_node("RoomShell") as Node2D
	var floor := shell.get_node("ArenaFloor") as Polygon2D
	var decorations := shell.get_node("RegionDecorations") as Node2D
	if (
		not floor.color.is_equal_approx(
			room.current_region.floor_color
		)
		or decorations.get_child_count() < 2
		or not decorations.has_node("GeneratedTileBackdrop")
		or not shell.modulate.is_equal_approx(Color.WHITE)
	):
		push_error("Region palette or decorations were not applied.")
		return false
	return true
