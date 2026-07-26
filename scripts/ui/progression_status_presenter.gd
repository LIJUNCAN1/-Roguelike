class_name ProgressionStatusPresenter
extends Node

@export_node_path("Node") var progression_path: NodePath
@export_node_path("Label") var experience_label_path: NodePath
@export_node_path("Label") var essence_label_path: NodePath

@onready var progression: RunProgression = get_node(
	progression_path
) as RunProgression
@onready var experience_label: Label = get_node(
	experience_label_path
) as Label
@onready var essence_label: Label = get_node(
	essence_label_path
) as Label


func _ready() -> void:
	progression.experience_changed.connect(_update_experience)
	progression.essence_changed.connect(_update_essence)
	_update_experience(
		progression.current_experience,
		progression.get_experience_to_next_level(),
		progression.level
	)
	_update_essence(progression.essence)


func _update_experience(
	current: int,
	required: int,
	level: int
) -> void:
	experience_label.text = "成长 Lv.%d：%d / %d" % [
		level,
		current,
		required,
	]


func _update_essence(current: int) -> void:
	essence_label.text = "基因精华：%d" % current
