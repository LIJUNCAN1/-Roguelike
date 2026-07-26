class_name AttackModifierStack
extends Node

@export var modifier_paths: Array[NodePath] = []

var modifiers: Array[Node] = []


func _ready() -> void:
	for modifier_path in modifier_paths:
		var modifier := get_node_or_null(modifier_path)
		if modifier != null and modifier.has_method("modify_attack"):
			modifiers.append(modifier)


func modify_attack(attack_context: AttackContext) -> void:
	for modifier in modifiers:
		modifier.call("modify_attack", attack_context)
