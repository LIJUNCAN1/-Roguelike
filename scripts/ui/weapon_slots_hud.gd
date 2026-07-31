class_name WeaponSlotsHud
extends Control

@export_node_path("Node") var weapon_manager_path: NodePath
@export var active_border_color := Color(1.0, 0.67, 0.18, 1.0)
@export var inactive_border_color := Color(0.28, 0.34, 0.4, 1.0)

@onready var weapon_manager: WeaponOrganManager = get_node(
	weapon_manager_path
) as WeaponOrganManager

var slot_organs: Array[WeaponOrganData] = []
var active_slot: int = -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	weapon_manager.weapon_slots_changed.connect(_update_slots)
	_update_slots(
		weapon_manager.get_equipped_organs(),
		weapon_manager.active_slot
	)


func _update_slots(
	organs: Array[WeaponOrganData],
	new_active_slot: int
) -> void:
	slot_organs.assign(organs)
	active_slot = new_active_slot
	queue_redraw()


func _draw() -> void:
	for slot_index in 2:
		var slot_rect := Rect2(
			Vector2(float(slot_index) * 33.0, 0.0),
			Vector2(30.0, 30.0)
		)
		var is_active := slot_index == active_slot
		draw_rect(slot_rect, Color(0.006, 0.012, 0.018, 0.96), true)
		draw_rect(
			slot_rect,
			active_border_color if is_active else inactive_border_color,
			false,
			2.0 if is_active else 1.0
		)
		draw_rect(
			slot_rect.grow(-4.0),
			Color(0.12, 0.07, 0.025, 0.65) if is_active
			else Color(0.025, 0.045, 0.06, 0.8),
			true
		)
		var organ: WeaponOrganData = (
			slot_organs[slot_index]
			if slot_index < slot_organs.size()
			else null
		)
		var symbol := "·"
		var symbol_color := Color(0.25, 0.3, 0.34, 1.0)
		if organ != null:
			symbol = organ.hud_symbol
			symbol_color = organ.hud_color
			var icon := organ.get_hud_icon()
			if icon != null:
				draw_texture_rect(icon, slot_rect.grow(-5.0), false)
				continue
		draw_string(
			ThemeDB.fallback_font,
			slot_rect.position + Vector2(0.0, 21.0),
			symbol,
			HORIZONTAL_ALIGNMENT_CENTER,
			slot_rect.size.x,
			14,
			symbol_color
		)


func get_slot_organ(slot_index: int) -> WeaponOrganData:
	if slot_index < 0 or slot_index >= slot_organs.size():
		return null
	return slot_organs[slot_index]
