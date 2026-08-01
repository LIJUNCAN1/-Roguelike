class_name ProgressionStatusPresenter
extends Node

@export_node_path("Node") var progression_path: NodePath
@export_node_path("Label") var coin_label_path: NodePath

@onready var progression: RunProgression = get_node(
	progression_path
) as RunProgression
@onready var coin_label: Label = get_node(
	coin_label_path
) as Label


func _ready() -> void:
	progression.coins_changed.connect(_update_coins)
	_update_coins(progression.coins)


func _update_coins(current: int) -> void:
	coin_label.text = str(current)
