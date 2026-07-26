extends Node

@export var debug_hotkeys_enabled: bool = false
@export var fire_gene: GeneData
@export var split_gene: GeneData
@export var piercing_gene: GeneData
@export var lifesteal_gene: GeneData
@export var explosion_gene: GeneData
@export_node_path("Node") var gene_manager_path: NodePath
@export_node_path("Node") var player_health_path: NodePath
@onready var gene_manager: GeneManager = get_node(
	gene_manager_path
) as GeneManager
@onready var player_health: HealthComponent = get_node(
	player_health_path
) as HealthComponent


func _unhandled_input(event: InputEvent) -> void:
	if not debug_hotkeys_enabled:
		return
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
