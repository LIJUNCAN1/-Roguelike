class_name PauseMenu
extends CanvasLayer

signal pause_changed(is_paused: bool)

@export_file("*.tscn") var title_scene_path: String = (
	"res://scenes/ui/title_screen.tscn"
)

@onready var dimmer: Control = $Dimmer
@onready var continue_button: Button = (
	$Dimmer/Panel/Margin/Content/Actions/ContinueButton
)
@onready var title_button: Button = (
	$Dimmer/Panel/Margin/Content/Actions/TitleButton
)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	dimmer.visible = false
	continue_button.pressed.connect(resume_game)
	title_button.pressed.connect(return_to_title)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause_game"):
		return
	if get_tree().paused and not dimmer.visible:
		return
	if dimmer.visible:
		resume_game()
	else:
		pause_game()
	get_viewport().set_input_as_handled()


func pause_game() -> bool:
	var run_flow := get_parent().get_node_or_null(
		"RunFlowController"
	) as RunFlowController
	if run_flow != null and run_flow.has_ended:
		return false
	dimmer.visible = true
	get_tree().paused = true
	continue_button.grab_focus()
	pause_changed.emit(true)
	return true


func resume_game() -> void:
	if not dimmer.visible:
		return
	dimmer.visible = false
	get_tree().paused = false
	pause_changed.emit(false)


func return_to_title() -> void:
	dimmer.visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file(title_scene_path)


func is_pause_visible() -> bool:
	return dimmer.visible
