class_name ItemInventoryHud
extends Control

@export_node_path("Node") var relic_manager_path: NodePath
@onready var relic_manager: RelicManager = get_node(
	relic_manager_path
) as RelicManager
@onready var item_list: VBoxContainer = $ItemList


func _ready() -> void:
	add_to_group("item_inventory_hud")
	relic_manager.relics_changed.connect(_rebuild)
	reload_inventory_settings()
	_rebuild()


func reload_inventory_settings() -> void:
	var preferences := DisplaySettingsStore.load_inventory_preferences()
	visible = bool(preferences.get("visible", true))
	var inventory_scale := clampf(
		float(preferences.get("scale", 1.0)),
		0.6,
		1.6
	)
	pivot_offset = Vector2(size.x, 0.0)
	scale = Vector2.ONE * inventory_scale


func _rebuild() -> void:
	for child in item_list.get_children():
		child.queue_free()
	for item in relic_manager.get_active_relics():
		item_list.add_child(_create_slot(item))


func _create_slot(item: RelicData) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(44, 44)
	panel.tooltip_text = "%s\n%s" % [item.display_name, item.description]
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.035, 0.045, 0.9)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.42, 0.7, 0.55, 0.9)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(40, 40)
	icon.texture = item.icon
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(icon)
	return panel
