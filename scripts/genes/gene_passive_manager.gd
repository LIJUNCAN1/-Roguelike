class_name GenePassiveManager
extends Node

signal passives_changed

@export_node_path("Node") var gene_manager_path: NodePath
@export_node_path("Node") var character_manager_path: NodePath
@export_node_path("Node") var health_component_path: NodePath
@export_node_path("Node") var movement_component_path: NodePath

@onready var gene_manager: GeneManager = get_node(
	gene_manager_path
) as GeneManager
@onready var character_manager: CharacterManager = get_node(
	character_manager_path
) as CharacterManager
@onready var health_component: HealthComponent = get_node(
	health_component_path
) as HealthComponent
@onready var movement_component: MovementComponent = get_node(
	movement_component_path
) as MovementComponent

var regeneration_per_second: float = 0.0


func _ready() -> void:
	gene_manager.genes_changed.connect(_recalculate)
	character_manager.character_changed.connect(
		func(_character: CharacterData) -> void: _recalculate()
	)
	call_deferred("_recalculate")


func _process(delta: float) -> void:
	if regeneration_per_second > 0.0:
		health_component.heal(regeneration_per_second * delta)


func _recalculate() -> void:
	var character := character_manager.current_character
	if character == null:
		return
	var health_multiplier := 1.0
	var movement_multiplier := 1.0
	var damage_multiplier := 1.0
	regeneration_per_second = 0.0
	for gene in gene_manager.get_active_genes():
		for passive in gene.passive_effects:
			if passive == null:
				continue
			health_multiplier *= passive.max_health_multiplier
			movement_multiplier *= passive.movement_speed_multiplier
			damage_multiplier *= passive.damage_taken_multiplier
			regeneration_per_second += (
				passive.health_regeneration_per_second
			)
	health_component.configure(
		character.max_health * health_multiplier,
		false
	)
	health_component.damage_taken_multiplier = damage_multiplier
	movement_component.configure(
		character.move_speed * movement_multiplier
	)
	passives_changed.emit()
