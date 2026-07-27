class_name WeaponOrganData
extends Resource

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var weapon_data: WeaponData

@export_group("HUD")
@export var hud_symbol: String = "◆"
@export var hud_color: Color = Color(1.0, 0.62, 0.18, 1.0)
