class_name WeaponAtlasPageData
extends Resource

@export var id: StringName
@export var atlas_texture: Texture2D
@export_range(1, 64, 1) var columns: int = 6
@export_range(1, 64, 1) var rows: int = 5
@export var cell_size: Vector2i = Vector2i(32, 32)


func get_icon(icon_index: int) -> AtlasTexture:
	if (
		atlas_texture == null
		or icon_index < 0
		or icon_index >= get_icon_count()
	):
		return null
	var texture := AtlasTexture.new()
	texture.atlas = atlas_texture
	texture.region = Rect2(
		Vector2i(
			(icon_index % columns) * cell_size.x,
			(icon_index / columns) * cell_size.y
		),
		cell_size
	)
	return texture


func get_icon_count() -> int:
	return columns * rows

