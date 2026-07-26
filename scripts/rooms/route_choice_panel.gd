class_name RouteChoicePanel
extends CanvasLayer

signal room_chosen(choice_index: int)

@onready var panel: PanelContainer = $Dimmer/Panel
@onready var choice_buttons: Array[Button] = [
	$Dimmer/Panel/Margin/Content/Choices/Choice1,
	$Dimmer/Panel/Margin/Content/Choices/Choice2,
]

var choices: Array[RoomData] = []


func _ready() -> void:
	for index in choice_buttons.size():
		choice_buttons[index].pressed.connect(
			_on_choice_pressed.bind(index)
		)
	hide_choices()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	var choice_index := -1
	if event.is_action_pressed("reward_choice_1"):
		choice_index = 0
	elif event.is_action_pressed("reward_choice_2"):
		choice_index = 1

	if choice_index >= 0 and choice_index < choices.size():
		room_chosen.emit(choice_index)
		get_viewport().set_input_as_handled()


func show_choices(room_choices: Array[RoomData]) -> void:
	choices.assign(room_choices)
	for index in choice_buttons.size():
		var button := choice_buttons[index]
		if index >= choices.size():
			button.visible = false
			continue
		var room := choices[index]
		button.visible = true
		button.disabled = false
		button.text = "%d\n%s\n\n%s" % [
			index + 1,
			room.display_name,
			_get_room_type_text(room.room_type),
		]
	visible = not choices.is_empty()


func hide_choices() -> void:
	choices.clear()
	visible = false


func _on_choice_pressed(choice_index: int) -> void:
	room_chosen.emit(choice_index)


func _get_room_type_text(room_type: int) -> String:
	match room_type:
		RoomData.RoomType.COMBAT:
			return "普通战斗"
		RoomData.RoomType.REWARD:
			return "获得基因"
		RoomData.RoomType.ELITE:
			return "高风险战斗"
		RoomData.RoomType.BOSS:
			return "区域首领"
		_:
			return "未知区域"
