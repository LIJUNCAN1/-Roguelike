extends Node

const CURSOR_ATLAS := preload(
	"res://assets/ui/cursors/controller_minimal.png"
)
const ICON_SIZE := Vector2i(16, 16)

var _current_shape: Input.CursorShape = Input.CURSOR_ARROW


func _ready() -> void:
	_register_cursor(Input.CURSOR_ARROW, Vector2i(0, 3))
	_register_cursor(Input.CURSOR_POINTING_HAND, Vector2i(6, 3))
	_register_cursor(Input.CURSOR_DRAG, Vector2i(11, 3))
	_register_cursor(Input.CURSOR_CROSS, Vector2i(0, 1))
	_register_cursor(Input.CURSOR_FORBIDDEN, Vector2i(14, 3))
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _process(_delta: float) -> void:
	var shape := _get_context_shape()
	if shape == _current_shape:
		return
	_current_shape = shape
	Input.set_default_cursor_shape(shape)


func _get_context_shape() -> Input.CursorShape:
	var viewport := get_viewport()
	var hovered := viewport.gui_get_hovered_control()
	if hovered is BaseButton:
		var button := hovered as BaseButton
		if button.disabled:
			return Input.CURSOR_FORBIDDEN
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			return Input.CURSOR_DRAG
		return Input.CURSOR_POINTING_HAND
	if _is_hovering_enemy(viewport):
		return Input.CURSOR_CROSS
	return Input.CURSOR_ARROW


func _is_hovering_enemy(viewport: Viewport) -> bool:
	var world := viewport.world_2d
	if world == null:
		return false
	var query := PhysicsPointQueryParameters2D.new()
	query.position = viewport.get_canvas_transform().affine_inverse() * (
		viewport.get_mouse_position()
	)
	query.collision_mask = 4
	query.collide_with_areas = true
	query.collide_with_bodies = true
	for result in world.direct_space_state.intersect_point(query, 8):
		var collider := result.get("collider") as Node
		if collider != null and collider.is_in_group(&"room_enemies"):
			return true
	return false


func _register_cursor(
	shape: Input.CursorShape,
	atlas_coordinate: Vector2i
) -> void:
	var texture := AtlasTexture.new()
	texture.atlas = CURSOR_ATLAS
	texture.region = Rect2(
		Vector2(atlas_coordinate * ICON_SIZE),
		Vector2(ICON_SIZE)
	)
	Input.set_custom_mouse_cursor(
		texture,
		shape,
		Vector2(8.0, 8.0)
	)
