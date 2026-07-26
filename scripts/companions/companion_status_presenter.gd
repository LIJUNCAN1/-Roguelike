class_name CompanionStatusPresenter
extends Node

@export_node_path("Node") var companion_manager_path: NodePath
@export_node_path("Label") var status_label_path: NodePath

@onready var companion_manager: CompanionManager = get_node(
	companion_manager_path
) as CompanionManager
@onready var status_label: Label = get_node(
	status_label_path
) as Label


func _ready() -> void:
	companion_manager.companion_changed.connect(_update_status)
	_update_status(companion_manager.current_companion)


func _update_status(companion: CompanionData) -> void:
	if companion == null:
		status_label.text = "伙伴：未选择"
		return
	status_label.text = "伙伴：%s" % companion.display_name
