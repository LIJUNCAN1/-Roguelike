class_name KeyboardActionIcon
extends Control

@export var actions: Array[StringName] = []

var atlas: Texture2D = preload("res://assets/ui/kb_dark_all.png")
var bindings: InputBindingManager


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bindings = get_node_or_null("/root/InputBindings") as InputBindingManager
	if bindings != null:
		bindings.bindings_changed.connect(_on_bindings_changed)
	queue_redraw()


func _draw() -> void:
	if bindings == null or actions.is_empty():
		return
	var textures: Array[AtlasTexture] = []
	for action in actions:
		var texture := KeyIconAtlas.texture_for_event(
			atlas,
			bindings.get_binding(action, InputBindingManager.DEVICE_KEYBOARD)
		)
		if texture != null:
			textures.append(texture)
	if textures.size() == 4:
		_draw_key(textures[0], Vector2(size.x * 0.5 - 12.0, 0.0))
		for index in 3:
			_draw_key(textures[index + 1], Vector2(size.x * 0.5 - 38.0 + index * 26.0, 28.0))
		return
	for index in textures.size():
		_draw_key(textures[index], Vector2((size.x - textures.size() * 26.0) * 0.5 + index * 26.0, (size.y - 24.0) * 0.5))


func _draw_key(texture: Texture2D, position: Vector2) -> void:
	draw_texture_rect(texture, Rect2(position, Vector2(24, 24)), false)


func _on_bindings_changed(device_type: StringName) -> void:
	if device_type == InputBindingManager.DEVICE_KEYBOARD:
		queue_redraw()
