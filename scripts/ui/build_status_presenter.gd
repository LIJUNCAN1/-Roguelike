class_name BuildStatusPresenter
extends Node

@export_node_path("Node") var gene_manager_path: NodePath
@export_node_path("Node") var fusion_manager_path: NodePath
@export_node_path("Node") var evolution_system_path: NodePath
@export_node_path("Node") var player_health_path: NodePath
@export_node_path("Label") var gene_label_path: NodePath
@export_node_path("Label") var fusion_label_path: NodePath
@export_node_path("Label") var evolution_label_path: NodePath
@export_node_path("Label") var health_label_path: NodePath

@onready var gene_manager: GeneManager = get_node(
	gene_manager_path
) as GeneManager
@onready var fusion_manager: FusionManager = get_node(
	fusion_manager_path
) as FusionManager
@onready var evolution_system: EvolutionSystem = get_node(
	evolution_system_path
) as EvolutionSystem
@onready var player_health: HealthComponent = get_node(
	player_health_path
) as HealthComponent
@onready var gene_label: Label = get_node(gene_label_path) as Label
@onready var fusion_label: Label = get_node(
	fusion_label_path
) as Label
@onready var evolution_label: Label = get_node(
	evolution_label_path
) as Label
@onready var health_label: Label = get_node(
	health_label_path
) as Label


func _ready() -> void:
	gene_manager.genes_changed.connect(_update_genes)
	fusion_manager.fusions_changed.connect(_update_fusions)
	evolution_system.evolution_changed.connect(
		_on_evolution_changed
	)
	player_health.health_changed.connect(_update_health)
	_update_genes()
	_update_fusions()
	_update_evolution()
	_update_health(
		player_health.current_health,
		player_health.max_health
	)


func _update_genes() -> void:
	var active_genes := gene_manager.get_active_genes()
	if active_genes.is_empty():
		gene_label.text = "基因：无"
		gene_label.modulate = Color(0.65, 0.72, 0.74, 1.0)
		return

	var gene_names := PackedStringArray()
	for gene in active_genes:
		gene_names.append(gene.display_name)
	gene_label.text = "基因：%s" % " + ".join(gene_names)
	gene_label.modulate = Color(1.0, 0.68, 0.3, 1.0)


func _update_fusions() -> void:
	var active_fusions := fusion_manager.get_active_fusions()
	if active_fusions.is_empty():
		fusion_label.text = "融合：未激活"
		fusion_label.modulate = Color(0.55, 0.6, 0.64, 1.0)
		return

	var fusion_names := PackedStringArray()
	for fusion in active_fusions:
		fusion_names.append(fusion.display_name)
	fusion_label.text = "融合：%s" % " + ".join(fusion_names)
	fusion_label.modulate = Color(1.0, 0.25, 0.08, 1.0)


func _on_evolution_changed(
	_previous_evolution: EvolutionData,
	_current_evolution: EvolutionData
) -> void:
	_update_evolution()


func _update_evolution() -> void:
	var evolution := evolution_system.get_current_evolution()
	if evolution == null:
		evolution_label.text = "形态：未知"
		return
	evolution_label.text = "形态：%s" % evolution.display_name
	evolution_label.modulate = Color(0.45, 0.9, 0.68, 1.0)


func _update_health(
	current_health: float,
	max_health: float
) -> void:
	health_label.text = "生命：%d / %d" % [
		roundi(current_health),
		roundi(max_health),
	]
