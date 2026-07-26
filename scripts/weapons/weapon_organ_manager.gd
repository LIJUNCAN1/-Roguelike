class_name WeaponOrganManager
extends Node

signal weapon_organ_changed(organ: WeaponOrganData)

@export var default_organ: WeaponOrganData
@export_node_path("Node") var weapon_component_path: NodePath

@onready var weapon_component: WeaponComponent = get_node(
	weapon_component_path
) as WeaponComponent

var current_organ: WeaponOrganData


func _ready() -> void:
	reset_to_default()


func equip_organ(organ: WeaponOrganData) -> bool:
	if (
		organ == null
		or organ.id.is_empty()
		or not weapon_component.set_weapon_data(organ.weapon_data)
	):
		return false
	current_organ = organ
	weapon_organ_changed.emit(organ)
	return true


func reset_to_default() -> bool:
	return equip_organ(default_organ)


func get_current_organ() -> WeaponOrganData:
	return current_organ


func is_organ(organ_id: StringName) -> bool:
	return current_organ != null and current_organ.id == organ_id
