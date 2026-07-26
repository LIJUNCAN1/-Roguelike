class_name RegionTileBackdrop
extends Node2D


func setup(data: RegionVisualData) -> void:
	if (
		data == null
		or data.source_atlas == null
		or data.sample_floor_region.size.x <= 0.0
		or data.sample_floor_region.size.y <= 0.0
	):
		return

	var world_size := data.floor_tile_world_size
	var columns := ceili(576.0 / world_size.x)
	var rows := ceili(296.0 / world_size.y)
	for row in rows:
		for column in columns:
			var tile := Sprite2D.new()
			tile.texture = data.source_atlas
			tile.region_enabled = true
			tile.region_rect = data.sample_floor_region
			tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			tile.scale = Vector2(
				world_size.x / data.sample_floor_region.size.x,
				world_size.y / data.sample_floor_region.size.y
			)
			tile.position = Vector2(
				32.0 + world_size.x * (column + 0.5),
				32.0 + world_size.y * (row + 0.5)
			)
			tile.modulate = Color(0.72, 0.78, 0.78, 0.5)
			add_child(tile)
