class_name LargeRoomTileBuilder
extends Node2D

@export var atlas_texture: Texture2D
@export var room_pixel_size: Vector2i = Vector2i(1920, 1080)
@export var tile_size: Vector2i = Vector2i(16, 16)
@export var floor_atlas_coordinates: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(2, 0),
]
@export var dirt_atlas_coordinates: Array[Vector2i] = [
	Vector2i(3, 0),
	Vector2i(4, 0),
]
@export var tree_atlas_coordinate: Vector2i = Vector2i(5, 0)
@export var rock_atlas_coordinates: Array[Vector2i] = [
	Vector2i(6, 0),
	Vector2i(7, 0),
]

@onready var ground: TileMapLayer = $Ground
@onready var details: TileMapLayer = $Details


func _ready() -> void:
	build_map()


func build_map() -> void:
	var texture := atlas_texture
	var atlas_coordinates: Array[Vector2i] = []
	atlas_coordinates.assign(floor_atlas_coordinates)
	var dirt_coordinates: Array[Vector2i] = []
	dirt_coordinates.assign(dirt_atlas_coordinates)
	var tree_coordinate := tree_atlas_coordinate
	var rock_coordinates: Array[Vector2i] = []
	rock_coordinates.assign(rock_atlas_coordinates)
	if texture == null:
		texture = _create_fallback_atlas()
		atlas_coordinates = [
			Vector2i(0, 0),
			Vector2i(1, 0),
			Vector2i(2, 0),
		]
		dirt_coordinates = [Vector2i(3, 0)]
		tree_coordinate = Vector2i(2, 0)
		rock_coordinates = [Vector2i(3, 0)]
	var tile_set := _create_tile_set(
		texture,
		atlas_coordinates,
		dirt_coordinates,
		tree_coordinate,
		rock_coordinates
	)
	ground.tile_set = tile_set
	details.tile_set = tile_set
	ground.clear()
	details.clear()
	var columns := ceili(float(room_pixel_size.x) / tile_size.x)
	var rows := ceili(float(room_pixel_size.y) / tile_size.y)
	var center := Vector2i(columns / 2, rows / 2)
	for y in rows:
		for x in columns:
			var variation: int = absi(
				(x * 17 + y * 31) % atlas_coordinates.size()
			)
			ground.set_cell(
				Vector2i(x, y),
				0,
				atlas_coordinates[variation]
			)
			var cell := Vector2i(x, y)
			if _is_dirt_cell(cell, center, columns, rows):
				var dirt_index: int = absi((x * 7 + y * 11) % dirt_coordinates.size())
				details.set_cell(cell, 0, dirt_coordinates[dirt_index])
			var edge_distance: int = mini(
				mini(x, columns - 1 - x),
				mini(y, rows - 1 - y)
			)
			if edge_distance <= 2 and (x + y) % 2 == 0:
				details.set_cell(cell, 0, tree_coordinate)
			elif (
				edge_distance >= 4
				and edge_distance <= 10
				and (x * 37 + y * 19) % 83 == 0
			):
				var rock_index: int = absi(
					(x * 5 + y * 3) % rock_coordinates.size()
				)
				details.set_cell(cell, 0, rock_coordinates[rock_index])


func _create_tile_set(
	texture: Texture2D,
	coordinates: Array[Vector2i],
	dirt_coordinates: Array[Vector2i],
	tree_coordinate: Vector2i,
	rock_coordinates: Array[Vector2i]
) -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = tile_size
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = tile_size
	tile_set.add_source(source, 0)
	var unique_coordinates: Array[Vector2i] = []
	unique_coordinates.assign(coordinates)
	for coordinate in dirt_coordinates:
		if not unique_coordinates.has(coordinate):
			unique_coordinates.append(coordinate)
	if not unique_coordinates.has(tree_coordinate):
		unique_coordinates.append(tree_coordinate)
	for coordinate in rock_coordinates:
		if not unique_coordinates.has(coordinate):
			unique_coordinates.append(coordinate)
	for coordinate in unique_coordinates:
		if not source.has_tile(coordinate):
			source.create_tile(coordinate)
	return tile_set


func _is_dirt_cell(
	cell: Vector2i,
	center: Vector2i,
	columns: int,
	rows: int
) -> bool:
	var offset := cell - center
	if offset.length_squared() <= 100:
		return true
	var horizontal_path := (
		absi(offset.y) <= 2
		and cell.x > 4
		and cell.x < columns - 5
	)
	var vertical_path := (
		absi(offset.x) <= 2
		and cell.y > 4
		and cell.y < rows - 5
	)
	return horizontal_path or vertical_path


func _create_fallback_atlas() -> Texture2D:
	var image := Image.create(64, 16, false, Image.FORMAT_RGBA8)
	var colors := [
		Color("40352f"),
		Color("493d35"),
		Color("382f2b"),
		Color("20283a"),
	]
	for tile_index in 4:
		for y in 16:
			for x in 16:
				var color: Color = colors[tile_index]
				if tile_index < 3 and ((x + y * 3 + tile_index) % 13 == 0):
					color = color.lightened(0.08)
				if tile_index == 3 and (x == 0 or y == 0):
					color = Color("31415a")
				image.set_pixel(tile_index * 16 + x, y, color)
	return ImageTexture.create_from_image(image)
