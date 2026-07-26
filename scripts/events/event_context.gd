class_name EventContext
extends RefCounted

var player: Node2D
var health_component: HealthComponent
var gene_manager: GeneManager
var rng: RandomNumberGenerator


func _init(player_node: Node2D, seed_value: int) -> void:
	player = player_node
	health_component = player.get_node_or_null(
		"HealthComponent"
	) as HealthComponent
	gene_manager = player.get_node_or_null(
		"GeneManager"
	) as GeneManager
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value
