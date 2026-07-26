class_name BuildNotificationPresenter
extends Node

@export_node_path("Node") var fusion_manager_path: NodePath
@export_node_path("Node") var evolution_system_path: NodePath
@export_node_path("Node") var gene_manager_path: NodePath
@export_node_path("Label") var notification_label_path: NodePath

@onready var fusion_manager: FusionManager = get_node(
	fusion_manager_path
) as FusionManager
@onready var evolution_system: EvolutionSystem = get_node(
	evolution_system_path
) as EvolutionSystem
@onready var gene_manager: GeneManager = get_node(
	gene_manager_path
) as GeneManager
@onready var notification_label: Label = get_node(
	notification_label_path
) as Label

var known_fusion_ids: Dictionary = {}
var known_gene_ids: Dictionary = {}
var active_tween: Tween


func _ready() -> void:
	for fusion in fusion_manager.get_active_fusions():
		known_fusion_ids[fusion.id] = true
	for gene in gene_manager.get_active_genes():
		known_gene_ids[gene.id] = true
	fusion_manager.fusions_changed.connect(_on_fusions_changed)
	evolution_system.evolution_changed.connect(_on_evolution_changed)
	gene_manager.genes_changed.connect(_on_genes_changed)
	notification_label.visible = false


func show_notification(text: String, color: Color) -> void:
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	notification_label.text = text
	notification_label.modulate = Color(color.r, color.g, color.b, 0.0)
	notification_label.visible = true
	active_tween = create_tween()
	active_tween.tween_property(
		notification_label,
		"modulate:a",
		1.0,
		0.16
	)
	active_tween.tween_interval(1.8)
	active_tween.tween_property(
		notification_label,
		"modulate:a",
		0.0,
		0.35
	)
	active_tween.tween_callback(
		func() -> void: notification_label.visible = false
	)


func _on_fusions_changed() -> void:
	for fusion in fusion_manager.get_active_fusions():
		if known_fusion_ids.has(fusion.id):
			continue
		known_fusion_ids[fusion.id] = true
		show_notification(
			"BUILD 共鸣：%s" % fusion.display_name,
			Color(1, 0.42, 0.12, 1)
		)


func _on_evolution_changed(
	previous: EvolutionData,
	current: EvolutionData
) -> void:
	if previous == null or current == null:
		return
	show_notification(
		"形态进化：%s" % current.display_name,
		Color(0.48, 1, 0.7, 1)
	)


func _on_genes_changed() -> void:
	var active_genes := gene_manager.get_active_genes()
	for gene in active_genes:
		if known_gene_ids.has(gene.id):
			continue
		known_gene_ids[gene.id] = true
		call_deferred("_show_gene_notification", gene)


func _show_gene_notification(gene: GeneData) -> void:
	if gene == null:
		return
	var related_names := PackedStringArray()
	for owned_gene in gene_manager.get_active_genes():
		if (
			owned_gene.id != gene.id
			and owned_gene.series_id == gene.series_id
		):
			related_names.append(owned_gene.display_name)
	var related_text := (
		"已有关联：%s" % "、".join(related_names)
		if not related_names.is_empty()
		else "当前暂无同系列基因"
	)
	show_notification(
		"获得：%s · %s · %s\n%s" % [
			gene.display_name,
			gene.get_rarity_name(),
			gene.get_category_name(),
			related_text,
		],
		Color(1, 0.88, 0.42, 1)
	)
