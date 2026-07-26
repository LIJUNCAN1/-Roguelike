class_name RouteExitSelector
extends Node2D

signal exit_entered(choice_index: int)

@onready var exits: Array[Area2D] = [
	$LeftExit,
	$RightExit,
]
@onready var labels: Array[Label] = [
	$LeftExit/RoomName,
	$RightExit/RoomName,
]

var choices: Array[RoomData] = []
var player: Node2D
var is_active: bool = false


func _ready() -> void:
	for index in exits.size():
		exits[index].body_entered.connect(
			_on_exit_body_entered.bind(index)
		)


func configure(
	room_choices: Array[RoomData],
	player_node: Node2D
) -> void:
	choices.assign(room_choices)
	player = player_node
	is_active = true

	for index in exits.size():
		var exit := exits[index]
		if index >= choices.size():
			exit.visible = false
			exit.monitoring = false
			continue
		exit.visible = true
		exit.monitoring = true
		labels[index].text = choices[index].display_name


func get_exit_global_position(choice_index: int) -> Vector2:
	if choice_index < 0 or choice_index >= exits.size():
		return global_position
	return exits[choice_index].global_position


func _on_exit_body_entered(
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
	for exit in exits:
		exit.set_deferred("monitoring", false)
	call_deferred("_emit_exit", choice_index)


func _emit_exit(choice_index: int) -> void:
	exit_entered.emit(choice_index)
