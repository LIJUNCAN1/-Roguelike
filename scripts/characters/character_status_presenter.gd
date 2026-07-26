extends Node

@export_node_path("Node") var character_manager_path: NodePath
@export_node_path("Node") var trait_manager_path: NodePath
@export_node_path("Label") var status_label_path: NodePath

@onready var character_manager: CharacterManager = get_node(
	character_manager_path
) as CharacterManager
@onready var trait_manager: CharacterTraitManager = get_node(
	trait_manager_path
) as CharacterTraitManager
@onready var status_label: Label = get_node(
	status_label_path
) as Label


func _ready() -> void:
	character_manager.character_changed.connect(_update_status)
	trait_manager.energy_changed.connect(_on_energy_changed)
	_update_status(character_manager.current_character)


func _update_status(character: CharacterData) -> void:
	if character == null:
		status_label.text = "角色：未选择"
		return
	var trait_name := (
		character.trait_data.display_name
		if character.trait_data != null
		else "无特性"
	)
	status_label.text = "角色：%s · %s" % [
		character.display_name,
		trait_name,
	]
	if trait_manager.get_max_energy() > 0.0:
		_on_energy_changed(
			trait_manager.current_energy,
			trait_manager.get_max_energy()
		)


func _on_energy_changed(
	current_energy: float,
	max_energy: float
) -> void:
	if max_energy <= 0.0:
		return
	var character := character_manager.current_character
	if character == null or character.trait_data == null:
		return
	status_label.text = "角色：%s · %s  能源 %.0f/%.0f" % [
		character.display_name,
		character.trait_data.display_name,
		current_energy,
		max_energy,
	]
