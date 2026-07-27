class_name WeaponOrganManager
extends Node

signal weapon_organ_changed(organ: WeaponOrganData)
signal weapon_slots_changed(
	organs: Array[WeaponOrganData],
	active_slot: int
)

@export var default_organ: WeaponOrganData
@export_node_path("Node") var weapon_component_path: NodePath

@onready var weapon_component: WeaponComponent = get_node(
	weapon_component_path
) as WeaponComponent

var current_organ: WeaponOrganData
var equipped_organs: Array[WeaponOrganData] = []
var active_slot: int = -1


func _ready() -> void:
	reset_to_default()


func equip_organ(organ: WeaponOrganData) -> bool:
	if (
		organ == null
		or organ.id.is_empty()
		or not weapon_component.set_weapon_data(organ.weapon_data)
	):
		return false
	var slot_index := _find_organ_slot(organ.id)
	if slot_index < 0:
		slot_index = _find_empty_slot()
	if slot_index < 0:
		slot_index = 0 if active_slot == 1 else 1
	equipped_organs[slot_index] = organ
	active_slot = slot_index
	current_organ = organ
	weapon_organ_changed.emit(organ)
	weapon_slots_changed.emit(get_equipped_organs(), active_slot)
	return true


func reset_to_default() -> bool:
	equipped_organs.clear()
	equipped_organs.resize(2)
	active_slot = -1
	return equip_organ(default_organ)


func get_current_organ() -> WeaponOrganData:
	return current_organ


func is_organ(organ_id: StringName) -> bool:
	return current_organ != null and current_organ.id == organ_id


func activate_slot(slot_index: int) -> bool:
	if (
		slot_index < 0
		or slot_index >= equipped_organs.size()
		or equipped_organs[slot_index] == null
	):
		return false
	return equip_organ(equipped_organs[slot_index])


func get_equipped_organs() -> Array[WeaponOrganData]:
	var organs: Array[WeaponOrganData] = []
	organs.assign(equipped_organs)
	return organs


func _find_organ_slot(organ_id: StringName) -> int:
	for slot_index in equipped_organs.size():
		var equipped := equipped_organs[slot_index]
		if equipped != null and equipped.id == organ_id:
			return slot_index
	return -1


func _find_empty_slot() -> int:
	for slot_index in equipped_organs.size():
		if equipped_organs[slot_index] == null:
			return slot_index
	return -1
