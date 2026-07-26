class_name EventChoiceSelector
extends Node2D

signal choice_entered(choice_index: int)

@onready var stations: Array[Area2D] = [
	$ChoiceA,
	$ChoiceB,
	$ChoiceC,
]
@onready var name_labels: Array[Label] = [
	$ChoiceA/Name,
	$ChoiceB/Name,
	$ChoiceC/Name,
]
@onready var description_labels: Array[Label] = [
	$ChoiceA/Description,
	$ChoiceB/Description,
	$ChoiceC/Description,
]

var choices: Array[EventChoiceData] = []
var player: Node2D
var is_active: bool = false


func _ready() -> void:
	for index in stations.size():
		stations[index].body_entered.connect(
			_on_station_body_entered.bind(index)
		)


func configure(
	event_choices: Array[EventChoiceData],
	player_node: Node2D
) -> void:
	choices.assign(event_choices)
	player = player_node
	is_active = true

	for index in stations.size():
		var station := stations[index]
		if index >= choices.size():
			station.visible = false
			station.monitoring = false
			continue
		station.visible = true
		station.monitoring = true
		name_labels[index].text = choices[index].display_name
		description_labels[index].text = choices[index].description


func get_choice_global_position(choice_index: int) -> Vector2:
	if choice_index < 0 or choice_index >= stations.size():
		return global_position
	return stations[choice_index].global_position


func _on_station_body_entered(
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
	for station in stations:
		station.set_deferred("monitoring", false)
	call_deferred("_emit_choice", choice_index)


func _emit_choice(choice_index: int) -> void:
	choice_entered.emit(choice_index)
