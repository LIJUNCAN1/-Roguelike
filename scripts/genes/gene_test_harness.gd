extends Node

@export var fire_gene: GeneData
@export var split_gene: GeneData
@export var piercing_gene: GeneData
@export var lifesteal_gene: GeneData
@export var explosion_gene: GeneData
@export_node_path("Node") var gene_manager_path: NodePath
@export_node_path("Node") var player_health_path: NodePath
@export_node_path("Label") var status_label_path: NodePath
@export_node_path("Label") var health_label_path: NodePath

@onready var gene_manager: GeneManager = get_node(
	gene_manager_path
) as GeneManager
@onready var status_label: Label = get_node(status_label_path) as Label
@onready var player_health: HealthComponent = get_node(
	player_health_path
) as HealthComponent
@onready var health_label: Label = get_node(
	health_label_path
) as Label


func _ready() -> void:
	gene_manager.genes_changed.connect(_update_status)
	player_health.health_changed.connect(_update_health_status)
	_update_status()
	_update_health_status(
		player_health.current_health,
		player_health.max_health
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("damage_test_player"):
		player_health.take_damage(30.0)
		get_viewport().set_input_as_handled()
		return

	var selected_gene: GeneData
	if event.is_action_pressed("toggle_test_gene"):
		selected_gene = fire_gene
	elif event.is_action_pressed("toggle_split_gene"):
		selected_gene = split_gene
	elif event.is_action_pressed("toggle_piercing_gene"):
		selected_gene = piercing_gene
	elif event.is_action_pressed("toggle_lifesteal_gene"):
		selected_gene = lifesteal_gene
	elif event.is_action_pressed("toggle_explosion_gene"):
		selected_gene = explosion_gene
	else:
		return

	if gene_manager.has_gene(selected_gene.id):
		gene_manager.remove_gene(selected_gene.id)
	else:
		gene_manager.add_gene(selected_gene)

	get_viewport().set_input_as_handled()


func _update_status() -> void:
	var active_genes := gene_manager.get_active_genes()
	if active_genes.is_empty():
		status_label.text = "基因：无"
		status_label.modulate = Color(0.65, 0.72, 0.74, 1.0)
		return

	var gene_names := PackedStringArray()
	for gene in active_genes:
		gene_names.append(gene.display_name)

	status_label.text = "基因：%s" % [
		" + ".join(gene_names)
	]
	status_label.modulate = Color(1.0, 0.68, 0.3, 1.0)


func _update_health_status(
	current_health: float,
	max_health: float
) -> void:
	health_label.text = "生命：%d / %d（P 扣血测试）" % [
		roundi(current_health),
		roundi(max_health)
	]
