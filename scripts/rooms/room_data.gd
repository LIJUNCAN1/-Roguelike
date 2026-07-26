class_name RoomData
extends Resource

enum RoomType {
	START,
	COMBAT,
	REWARD,
	ELITE,
	BOSS,
	EVENT,
	RELIC,
	SHOP,
}

@export var id: StringName
@export var display_name: String
@export var room_type: RoomType = RoomType.COMBAT
@export var room_scene: PackedScene
@export var region: RegionData
@export var gene_reward_pool: GeneRewardPoolData
