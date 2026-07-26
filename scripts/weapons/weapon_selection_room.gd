class_name WeaponSelectionRoom
extends RoomController

signal weapon_selected(organ: WeaponOrganData)
signal companion_selected(companion: CompanionData)

@export var weapon_choices: Array[WeaponOrganData] = []
@export var character_choices: Array[CharacterData] = []
@export var companion_choices: Array[CompanionData] = []

@onready var character_selector: CharacterChoiceSelector = $CharacterChoiceSelector
@onready var choice_selector: WeaponChoiceSelector = $WeaponChoiceSelector
@onready var companion_selector: CompanionChoiceSelector = $CompanionChoiceSelector
@onready var result_label: Label = $Result

var weapon_manager: WeaponOrganManager
var character_manager: CharacterManager
var companion_manager: CompanionManager
var player: Node2D
var selected_character: CharacterData
var selected_organ: WeaponOrganData
var selected_companion: CompanionData


func _ready() -> void:
	completion_mode = CompletionMode.EXTERNAL
	result_label.visible = false
	character_selector.character_entered.connect(_on_character_entered)
	choice_selector.organ_entered.connect(_on_organ_entered)
	companion_selector.companion_entered.connect(_on_companion_entered)
	choice_selector.visible = false
	companion_selector.visible = false


func configure_run(player: Node2D, _run_seed: int) -> void:
	self.player = player
	character_manager = player.get_node_or_null(
		"CharacterManager"
	) as CharacterManager
	weapon_manager = player.get_node_or_null(
		"WeaponOrganManager"
	) as WeaponOrganManager
	companion_manager = player.get_node_or_null(
		"CompanionManager"
	) as CompanionManager
	if (
		character_manager == null
		or weapon_manager == null
		or companion_manager == null
		or character_choices.is_empty()
		or weapon_choices.is_empty()
		or companion_choices.is_empty()
	):
		push_error(
			"Start room requires character, weapon and companion choices."
		)
		return
	character_selector.visible = true
	character_selector.configure(character_choices, player)


func get_incomplete_hint() -> String:
	if selected_character == null:
		return "走进一个孵化舱选择角色"
	if selected_organ == null:
		return "走进一个培养舱选择攻击器官"
	return "走进一个共生舱选择伙伴"


func _on_character_entered(choice_index: int) -> void:
	if (
		selected_character != null
		or choice_index < 0
		or choice_index >= character_choices.size()
	):
		return
	var character := character_choices[choice_index]
	if not character_manager.select_character(character):
		return
	selected_character = character
	character_selector.visible = false
	player.global_position = Vector2(320, 180)
	choice_selector.visible = true
	choice_selector.configure(weapon_choices, player)
	result_label.text = "已选择：%s · 继续选择攻击器官" % [
		character.display_name
	]
	result_label.visible = true


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
	choice_selector.visible = false
	player.global_position = Vector2(320, 180)
	companion_selector.visible = true
	companion_selector.configure(companion_choices, player)
	result_label.text = "已装载：%s · 继续选择伙伴" % organ.display_name
	result_label.visible = true
	weapon_selected.emit(organ)


func _on_companion_entered(choice_index: int) -> void:
	if (
		is_completed
		or choice_index < 0
		or choice_index >= companion_choices.size()
	):
		return
	var companion := companion_choices[choice_index]
	if not companion_manager.select_companion(companion):
		return
	selected_companion = companion
	result_label.text = "已选择：%s · 按 N 出发" % companion.display_name
	result_label.visible = true
	companion_selected.emit(companion)
	_mark_completed()
