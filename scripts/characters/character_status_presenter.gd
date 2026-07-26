extends Node

@export_node_path("Node") var character_manager_path: NodePath
@export_node_path("Label") var status_label_path: NodePath

@onready var character_manager: CharacterManager = get_node(
	character_manager_path
) as CharacterManager
@onready var status_label: Label = get_node(
	status_label_path
) as Label


func _ready() -> void:
	character_manager.character_changed.connect(_update_status)
	_update_status(character_manager.current_character)


func _update_status(character: CharacterData) -> void:
	if character == null:
		status_label.text = "角色：未选择"
		return
	status_label.text = "角色：%s" % character.display_name
