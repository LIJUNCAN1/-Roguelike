class_name KeyIconAtlas
extends RefCounted

const CELL_SIZE := 16


static func texture_for_event(atlas: Texture2D, event: InputEvent) -> AtlasTexture:
	if atlas == null or not event is InputEventKey:
		return null
	var key_event := event as InputEventKey
	var code := key_event.physical_keycode if key_event.physical_keycode != 0 else key_event.keycode
	var region := _region_for_key(code)
	if region.size == Vector2.ZERO:
		return null
	var texture := AtlasTexture.new()
	texture.atlas = atlas
	texture.region = region
	return texture


static func _region_for_key(code: Key) -> Rect2:
	if code >= KEY_A and code <= KEY_Z:
		return Rect2(0, int(code - KEY_A) * CELL_SIZE, CELL_SIZE, CELL_SIZE)
	match code:
		KEY_ESCAPE:
			return Rect2(112, 0, CELL_SIZE, CELL_SIZE)
		KEY_SPACE:
			return Rect2(96, 64, 32, CELL_SIZE)
		KEY_ENTER:
			return Rect2(208, 128, 32, CELL_SIZE)
		KEY_TAB:
			return Rect2(96, 48, 32, CELL_SIZE)
	return Rect2()

