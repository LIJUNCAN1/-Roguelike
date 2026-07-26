class_name RelicStatusPresenter
extends Node

@export_node_path("Node") var relic_manager_path: NodePath
@export_node_path("Label") var status_label_path: NodePath

@onready var relic_manager: RelicManager = get_node(
	relic_manager_path
) as RelicManager
@onready var status_label: Label = get_node(
	status_label_path
) as Label


func _ready() -> void:
	relic_manager.relics_changed.connect(_update_status)
	_update_status()


func _update_status() -> void:
	var relics := relic_manager.get_active_relics()
	if relics.is_empty():
		status_label.text = "秘宝：无"
		status_label.modulate = Color(0.58, 0.64, 0.66, 1.0)
		return

	var names := PackedStringArray()
	for relic in relics:
		names.append(relic.display_name)
	status_label.text = "秘宝：%s" % " + ".join(names)
	status_label.modulate = Color(1.0, 0.62, 0.24, 1.0)
