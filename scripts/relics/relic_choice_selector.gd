class_name RelicChoiceSelector
extends Node2D

signal relic_entered(choice_index: int)

@onready var pedestals: Array[Area2D] = [
	$LeftPedestal,
	$RightPedestal,
]
@onready var name_labels: Array[Label] = [
	$LeftPedestal/Name,
	$RightPedestal/Name,
]
@onready var description_labels: Array[Label] = [
	$LeftPedestal/Description,
	$RightPedestal/Description,
]

var choices: Array[RelicData] = []
var player: Node2D
var is_active: bool = false


func _ready() -> void:
	for index in pedestals.size():
		pedestals[index].body_entered.connect(
			_on_pedestal_body_entered.bind(index)
		)


func configure(
	relic_choices: Array[RelicData],
	player_node: Node2D
) -> void:
	choices.assign(relic_choices)
	player = player_node
	is_active = true
	for index in pedestals.size():
		var pedestal := pedestals[index]
		if index >= choices.size():
			pedestal.visible = false
			pedestal.monitoring = false
			continue
		pedestal.visible = true
		pedestal.monitoring = true
		name_labels[index].text = choices[index].display_name
		description_labels[index].text = choices[index].description


func get_choice_global_position(choice_index: int) -> Vector2:
	if choice_index < 0 or choice_index >= pedestals.size():
		return global_position
	return pedestals[choice_index].global_position


func _on_pedestal_body_entered(
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
	for pedestal in pedestals:
		pedestal.set_deferred("monitoring", false)
	call_deferred("_emit_relic", choice_index)


func _emit_relic(choice_index: int) -> void:
	relic_entered.emit(choice_index)
