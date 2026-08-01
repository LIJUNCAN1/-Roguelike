class_name RunFlowController
extends Node

signal run_ended(victory: bool)
signal run_restarted

@export_node_path("Node") var room_manager_path: NodePath
@export_node_path("Node2D") var player_path: NodePath
@export_node_path("CanvasLayer") var result_panel_path: NodePath

@onready var room_manager: RoomManager = get_node(
	room_manager_path
) as RoomManager
@onready var player: Node2D = get_node(player_path) as Node2D
@onready var health_component: HealthComponent = player.get_node(
	"HealthComponent"
) as HealthComponent
@onready var gene_manager: GeneManager = player.get_node(
	"GeneManager"
) as GeneManager
@onready var relic_manager: RelicManager = player.get_node(
	"RelicManager"
) as RelicManager
@onready var weapon_manager: WeaponOrganManager = player.get_node(
	"WeaponOrganManager"
) as WeaponOrganManager
@onready var character_manager: CharacterManager = player.get_node(
	"CharacterManager"
) as CharacterManager
@onready var companion_manager: CompanionManager = player.get_node(
	"CompanionManager"
) as CompanionManager
@onready var run_progression: RunProgression = player.get_node(
	"RunProgression"
) as RunProgression
@onready var result_panel: RunResultPanel = get_node(
	result_panel_path
) as RunResultPanel

var has_ended: bool = false
var was_victory: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	health_component.died.connect(_on_player_died)
	room_manager.run_completed.connect(_on_run_completed)


func _unhandled_input(event: InputEvent) -> void:
	if has_ended and event.is_action_pressed("restart_run"):
		restart_run()
		get_viewport().set_input_as_handled()


func restart_run(seed_value: int = 0) -> bool:
	if not has_ended:
		return false

	get_tree().paused = false
	gene_manager.clear_genes()
	relic_manager.clear_relics()
	weapon_manager.reset_to_default()
	character_manager.reset_to_default()
	companion_manager.reset_to_default()
	run_progression.reset()
	player.set_physics_process(true)
	player.visible = true

	var max_health := health_component.max_health
	var character_data := player.get("character_data") as CharacterData
	if character_data != null:
		max_health = character_data.max_health
	health_component.configure(max_health)

	has_ended = false
	was_victory = false
	result_panel.hide_result()
	if not room_manager.restart_run(seed_value):
		return false
	run_restarted.emit()
	return true


func _on_player_died(_source: Node) -> void:
	_end_run(false)


func _on_run_completed() -> void:
	_end_run(true)


func _end_run(victory: bool) -> void:
	if has_ended:
		return

	has_ended = true
	was_victory = victory
	var base_meta_reward := maxi(
		room_manager.current_room_index + 1
		+ run_progression.coins / 2
		+ (10 if victory else 0),
		1
	)
	var meta_progression := get_node(
		"/root/MetaProgression"
	) as MetaProgressionManager
	var meta_reward := meta_progression.award_currency(
		base_meta_reward
	)
	result_panel.show_result(
		victory,
		room_manager.current_route_seed,
		gene_manager.get_active_genes().size(),
		meta_reward,
		meta_progression.currency
	)
	get_tree().paused = true
	run_ended.emit(victory)
