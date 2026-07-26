class_name WeaponSelectionRoom
extends RoomController

signal weapon_selected(organ: WeaponOrganData)

@export var weapon_choices: Array[WeaponOrganData] = []

@onready var choice_selector: WeaponChoiceSelector = $WeaponChoiceSelector
@onready var result_label: Label = $Result

var weapon_manager: WeaponOrganManager
var selected_organ: WeaponOrganData


func _ready() -> void:
	completion_mode = CompletionMode.EXTERNAL
	result_label.visible = false
	choice_selector.organ_entered.connect(_on_organ_entered)


func configure_run(player: Node2D, _run_seed: int) -> void:
	weapon_manager = player.get_node_or_null(
		"WeaponOrganManager"
	) as WeaponOrganManager
	if weapon_manager == null or weapon_choices.is_empty():
		push_error("WeaponSelectionRoom requires weapon choices.")
		return
	choice_selector.configure(weapon_choices, player)


func get_incomplete_hint() -> String:
	return "走进一个培养舱选择攻击器官"


func _on_organ_entered(choice_index: int) -> void:
	if (
		is_completed
		or choice_index < 0
		or choice_index >= weapon_choices.size()
	):
		return
	var organ := weapon_choices[choice_index]
	if not weapon_manager.equip_organ(organ):
		return
	selected_organ = organ
	result_label.text = "已装载：%s · 按 N 出发" % organ.display_name
	result_label.visible = true
	weapon_selected.emit(organ)
	_mark_completed()
