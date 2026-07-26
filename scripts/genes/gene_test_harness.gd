extends Node

@export var test_gene: GeneData
@export_node_path("Node") var gene_manager_path: NodePath
@export_node_path("Label") var status_label_path: NodePath

@onready var gene_manager: GeneManager = get_node(
	gene_manager_path
) as GeneManager
@onready var status_label: Label = get_node(status_label_path) as Label


func _ready() -> void:
	gene_manager.genes_changed.connect(_update_status)
	_update_status()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("toggle_test_gene"):
		return

	if gene_manager.has_gene(test_gene.id):
		gene_manager.remove_gene(test_gene.id)
	else:
		gene_manager.add_gene(test_gene)

	get_viewport().set_input_as_handled()


func _update_status() -> void:
	if gene_manager.has_gene(test_gene.id):
		status_label.text = "基因：火焰（伤害 15 · 火焰弹）"
		status_label.modulate = Color(1.0, 0.55, 0.25, 1.0)
	else:
		status_label.text = "基因：无（按 G 装备火焰基因）"
		status_label.modulate = Color(0.65, 0.72, 0.74, 1.0)
