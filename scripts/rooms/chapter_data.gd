class_name ChapterData
extends Resource

@export var id: StringName
@export var display_name: String
@export var region: RegionData
@export_range(0, 100, 1) var start_room_index: int
@export_range(0, 100, 1) var end_room_index: int
@export var enemy_ids: Array[StringName] = []
@export var reward_pool: GeneRewardPoolData
@export var boss_room_ids: Array[StringName] = []


func contains_room(room_index: int) -> bool:
	return (
		room_index >= start_room_index
		and room_index <= end_room_index
	)
