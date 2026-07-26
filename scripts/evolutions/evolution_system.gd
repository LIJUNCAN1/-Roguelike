class_name EvolutionSystem
extends Node

signal evolution_changed(
	previous_evolution: EvolutionData,
	current_evolution: EvolutionData
)

@export_node_path("Node") var gene_manager_path: NodePath
@export_node_path("Node") var fusion_manager_path: NodePath
@export_node_path("Node2D") var visual_anchor_path: NodePath
@export_node_path("Node2D") var pixel_presenter_path: NodePath
@export var base_evolution: EvolutionData
@export var evolutions: Array[EvolutionData] = []

@onready var gene_manager: GeneManager = get_node(
	gene_manager_path
) as GeneManager
@onready var fusion_manager: FusionManager = get_node(
	fusion_manager_path
) as FusionManager
@onready var visual_anchor: Node2D = get_node(
	visual_anchor_path
) as Node2D
@onready var pixel_presenter: PixelActorPresenter = get_node_or_null(
	pixel_presenter_path
) as PixelActorPresenter

var current_evolution: EvolutionData


func _ready() -> void:
	gene_manager.genes_changed.connect(_evaluate_evolution)
	fusion_manager.fusions_changed.connect(_evaluate_evolution)
	_evaluate_evolution()


func get_current_evolution() -> EvolutionData:
	return current_evolution


func is_evolution(evolution_id: StringName) -> bool:
	return (
		current_evolution != null
		and current_evolution.id == evolution_id
	)


func set_base_evolution(evolution: EvolutionData) -> bool:
	if evolution == null:
		return false
	base_evolution = evolution
	if is_node_ready():
		_evaluate_evolution()
	return true


func modify_attack(attack_context: AttackContext) -> void:
	if current_evolution == null:
		return

	for effect in current_evolution.effects:
		if effect != null:
			effect.apply(attack_context)


func _evaluate_evolution() -> void:
	var selected_evolution := base_evolution
	for evolution in evolutions:
		if (
			evolution != null
			and evolution.requirements_met(
				gene_manager,
				fusion_manager
			)
			and (
				selected_evolution == null
				or evolution.priority > selected_evolution.priority
			)
		):
			selected_evolution = evolution

	_set_evolution(selected_evolution)


func _set_evolution(next_evolution: EvolutionData) -> void:
	if next_evolution == null:
		push_error("EvolutionSystem requires a base evolution.")
		return

	if (
		current_evolution != null
		and current_evolution.id == next_evolution.id
	):
		return

	var previous_evolution := current_evolution
	current_evolution = next_evolution
	_replace_visual(current_evolution.visual_scene)
	if pixel_presenter != null:
		pixel_presenter.configure(current_evolution.pixel_visual_data)
		pixel_presenter.play_evolution()
	evolution_changed.emit(previous_evolution, current_evolution)


func _replace_visual(visual_scene: PackedScene) -> void:
	for child in visual_anchor.get_children():
		visual_anchor.remove_child(child)
		child.queue_free()

	if visual_scene == null:
		return

	visual_anchor.add_child(visual_scene.instantiate())
