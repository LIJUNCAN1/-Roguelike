class_name TestRoomHelpers
extends RefCounted


static func enter_combat_room(main: Node) -> RoomController:
	var room_manager := main.get_node("RoomManager") as RoomManager
	if not room_manager.enter_room(1):
		push_error("Test could not enter the combat room.")
		return null
	return room_manager.current_room
