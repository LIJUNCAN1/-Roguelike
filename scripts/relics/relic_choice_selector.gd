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
@onready var relic_icons: Array[Sprite2D] = [
	$LeftPedestal/RelicIcon,
	$RightPedestal/RelicIcon,
]

var choices: Array[RelicData] = []
var player: Node2D
var is_active: bool = false
var float_time := 0.0


func _ready() -> void:
	for index in pedestals.size():
		pedestals[index].body_entered.connect(
			_on_pedestal_body_entered.bind(index)
		)


func _process(delta: float) -> void:
	float_time += delta
	for index in relic_icons.size():
		var icon := relic_icons[index]
		icon.position.y = -40.0 + sin(float_time * 2.4 + index * 0.8) * 4.0


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
		relic_icons[index].texture = choices[index].icon
		relic_icons[index].visible = choices[index].icon != null


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
