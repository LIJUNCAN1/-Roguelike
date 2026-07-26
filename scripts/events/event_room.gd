class_name EventRoom
extends RoomController

signal event_choice_resolved(choice: EventChoiceData)

@export var event_data: EventData

@onready var event_title: Label = $EventTitle
@onready var event_description: Label = $EventDescription
@onready var result_label: Label = $Result
@onready var choice_selector: EventChoiceSelector = $EventChoiceSelector

var event_context: EventContext
var selected_choice: EventChoiceData


func _ready() -> void:
	completion_mode = CompletionMode.EXTERNAL
	result_label.visible = false
	choice_selector.choice_entered.connect(_on_choice_entered)


func configure_run(player: Node2D, run_seed: int) -> void:
	if event_data == null:
		push_error("EventRoom requires EventData.")
		return

	event_title.text = event_data.display_name
	event_description.text = event_data.description
	event_context = EventContext.new(player, run_seed + 65537)
	choice_selector.configure(event_data.choices, player)


func get_incomplete_hint() -> String:
	return "走进一个实验舱做出选择"


func _on_choice_entered(choice_index: int) -> void:
	if (
		is_completed
		or event_data == null
		or choice_index < 0
		or choice_index >= event_data.choices.size()
	):
		return

	selected_choice = event_data.choices[choice_index]
	selected_choice.apply(event_context)
	result_label.text = "已选择：%s · 按 N 前进" % [
		selected_choice.display_name
	]
	result_label.visible = true
	event_choice_resolved.emit(selected_choice)
	_mark_completed()
