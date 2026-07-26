class_name RegionVisualData
extends Resource

@export_group("Replacement Assets")
@export var tile_set: TileSet
@export var environment_scene: PackedScene
@export var background_texture: Texture2D

@export_group("Generated Atlas Reference")
@export var source_atlas: Texture2D
@export var source_region: Rect2
@export var sample_floor_region: Rect2
@export var floor_tile_world_size: Vector2 = Vector2(72, 72)
@export_multiline var replacement_notes: String
