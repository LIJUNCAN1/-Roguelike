class_name ProgressionStatusPresenter
extends Node

@export_node_path("Node") var progression_path: NodePath
@export_node_path("Label") var essence_label_path: NodePath

@onready var progression: RunProgression = get_node(
	progression_path
) as RunProgression
@onready var essence_label: Label = get_node(
	essence_label_path
) as Label


func _ready() -> void:
	progression.essence_changed.connect(_update_essence)
	_update_essence(progression.essence)


func _update_essence(current: int) -> void:
	essence_label.text = "× %d" % current
