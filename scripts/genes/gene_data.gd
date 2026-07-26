class_name GeneData
extends Resource

@export_group("Identity")
@export var id: StringName
@export var display_name: String
@export_multiline var description: String

@export_group("Codex")
@export var series_id: StringName
@export var series_name: String

@export_group("Effects")
@export var effects: Array[GeneEffect] = []
