class_name RouteRoomPoolData
extends Resource

@export var rooms: Array[RoomData] = []


func get_valid_rooms() -> Array[RoomData]:
	var valid_rooms: Array[RoomData] = []
	for room in rooms:
		if room != null and room.room_scene != null:
			valid_rooms.append(room)
	return valid_rooms
