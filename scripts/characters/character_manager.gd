class_name CharacterManager
extends Node

signal character_changed(character: CharacterData)

@export var default_character: CharacterData
@export_node_path("Node") var evolution_system_path: NodePath
@export_node_path("Node") var trait_manager_path: NodePath

@onready var player: CharacterBody2D = get_parent() as CharacterBody2D
@onready var evolution_system: EvolutionSystem = get_node(
	evolution_system_path
) as EvolutionSystem
@onready var trait_manager: CharacterTraitManager = get_node(
	trait_manager_path
) as CharacterTraitManager

var current_character: CharacterData


func _ready() -> void:
	call_deferred("reset_to_default")


func select_character(character: CharacterData) -> bool:
	if (
		character == null
		or character.id.is_empty()
		or character.base_evolution == null
		or not player.call("apply_character_data", character)
		or not evolution_system.set_base_evolution(
			character.base_evolution
		)
	):
		return false
	current_character = character
	trait_manager.configure(character.trait_data)
	character_changed.emit(character)
	return true


func reset_to_default() -> bool:
	return select_character(default_character)


func is_character(character_id: StringName) -> bool:
	return (
		current_character != null
		and current_character.id == character_id
	)
