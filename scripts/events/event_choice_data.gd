class_name EventChoiceData
extends Resource

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var effects: Array[EventEffect] = []


func apply(context: EventContext) -> void:
	for effect in effects:
		if effect != null:
			effect.apply(context)
