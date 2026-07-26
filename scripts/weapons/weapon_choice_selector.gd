class_name WeaponChoiceSelector
extends Node2D

signal organ_entered(choice_index: int)

@onready var chambers: Array[Area2D] = [
	$LeftChamber,
	$RightChamber,
]
@onready var name_labels: Array[Label] = [
	$LeftChamber/Name,
	$RightChamber/Name,
]
@onready var description_labels: Array[Label] = [
	$LeftChamber/Description,
	$RightChamber/Description,
]

var choices: Array[WeaponOrganData] = []
var player: Node2D
var is_active: bool = false
var _arming_frames: int = 0


func _ready() -> void:
	for index in chambers.size():
		chambers[index].body_entered.connect(
			_on_chamber_body_entered.bind(index)
		)
	set_physics_process(false)


func configure(
	organ_choices: Array[WeaponOrganData],
	player_node: Node2D
) -> void:
	choices.assign(organ_choices)
	player = player_node
	is_active = false
	_arming_frames = 2
	for index in chambers.size():
		var chamber := chambers[index]
		chamber.monitoring = false
		if index >= choices.size():
			chamber.visible = false
			continue
		chamber.visible = true
		name_labels[index].text = choices[index].display_name
		description_labels[index].text = choices[index].description
	set_physics_process(true)


func _physics_process(_delta: float) -> void:
	_arming_frames -= 1
	if _arming_frames > 0:
		return
	is_active = true
	for index in chambers.size():
		if index < choices.size():
			chambers[index].set_deferred("monitoring", true)
	set_physics_process(false)


func get_choice_global_position(choice_index: int) -> Vector2:
	if choice_index < 0 or choice_index >= chambers.size():
		return global_position
	return chambers[choice_index].global_position


func _on_chamber_body_entered(
	body: Node2D,
	choice_index: int
) -> void:
	if (
		not is_active
		or body != player
		or choice_index < 0
		or choice_index >= choices.size()
	):
		return
	is_active = false
	for chamber in chambers:
		chamber.set_deferred("monitoring", false)
	call_deferred("_emit_organ", choice_index)


func _emit_organ(choice_index: int) -> void:
	organ_entered.emit(choice_index)
