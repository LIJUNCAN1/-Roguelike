class_name FusionManager
extends Node

signal fusions_changed

@export_node_path("Node") var gene_manager_path: NodePath
@export var fusion_recipes: Array[FusionData] = []

@onready var gene_manager: GeneManager = get_node(
	gene_manager_path
) as GeneManager

var active_fusions: Array[FusionData] = []


func _ready() -> void:
	gene_manager.genes_changed.connect(_evaluate_fusions)
	_evaluate_fusions()


func get_active_fusions() -> Array[FusionData]:
	var fusions_copy: Array[FusionData] = []
	fusions_copy.assign(active_fusions)
	return fusions_copy


func has_fusion(fusion_id: StringName) -> bool:
	for fusion in active_fusions:
		if fusion.id == fusion_id:
			return true
	return false


func modify_attack(attack_context: AttackContext) -> void:
	for fusion in active_fusions:
		for effect in fusion.effects:
			if effect != null:
				effect.apply(attack_context)


func _evaluate_fusions() -> void:
	var next_fusions: Array[FusionData] = []
	for fusion in fusion_recipes:
		if fusion != null and fusion.requirements_met(gene_manager):
			next_fusions.append(fusion)

	if _same_fusions(active_fusions, next_fusions):
		return

	active_fusions.assign(next_fusions)
	fusions_changed.emit()


func _same_fusions(
	current: Array[FusionData],
	next: Array[FusionData]
) -> bool:
	if current.size() != next.size():
		return false

	for index in current.size():
		if current[index].id != next[index].id:
			return false
	return true
