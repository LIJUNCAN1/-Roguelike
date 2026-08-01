class_name RelicManager
extends Node

signal relics_changed
signal relic_added(relic: RelicData)

@export var starting_relics: Array[RelicData] = []

var active_relics: Array[RelicData] = []


func _ready() -> void:
	for relic in starting_relics:
		add_relic(relic)


func add_relic(relic: RelicData) -> bool:
	if relic == null or relic.id.is_empty() or has_relic(relic.id):
		return false
	active_relics.append(relic)
	relic_added.emit(relic)
	relics_changed.emit()
	return true


func remove_relic(relic_id: StringName) -> bool:
	for index in active_relics.size():
		if active_relics[index].id == relic_id:
			active_relics.remove_at(index)
			relics_changed.emit()
			return true
	return false


func clear_relics() -> void:
	if active_relics.is_empty():
		return
	active_relics.clear()
	relics_changed.emit()


func has_relic(relic_id: StringName) -> bool:
	for relic in active_relics:
		if relic.id == relic_id:
			return true
	return false


func get_active_relics() -> Array[RelicData]:
	var relics_copy: Array[RelicData] = []
	relics_copy.assign(active_relics)
	return relics_copy


func modify_attack(attack_context: AttackContext) -> void:
	for relic in active_relics:
		for effect in relic.effects:
			if effect != null:
				effect.apply(attack_context)
