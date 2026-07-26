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
	result_panel.show_result(
		victory,
		room_manager.current_route_seed,
		gene_manager.get_active_genes().size()
	)
	get_tree().paused = true
	run_ended.emit(victory)
