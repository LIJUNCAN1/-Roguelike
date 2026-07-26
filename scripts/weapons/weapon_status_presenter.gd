extends Node

@export_node_path("Node") var weapon_manager_path: NodePath
@export_node_path("Label") var status_label_path: NodePath

@onready var weapon_manager: WeaponOrganManager = get_node(
	weapon_manager_path
) as WeaponOrganManager
@onready var status_label: Label = get_node(
	status_label_path
) as Label


func _ready() -> void:
	weapon_manager.weapon_organ_changed.connect(_update_status)
	_update_status(weapon_manager.get_current_organ())


func _update_status(organ: WeaponOrganData) -> void:
	if organ == null:
		status_label.text = "攻击器官：未选择"
		return
	status_label.text = "攻击器官：%s" % organ.display_name
