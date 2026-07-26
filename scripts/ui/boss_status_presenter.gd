class_name BossStatusPresenter
extends Node

@export_node_path("Node") var room_manager_path: NodePath
@export_node_path("Control") var boss_panel_path: NodePath
@export_node_path("Label") var boss_name_label_path: NodePath
@export_node_path("ProgressBar") var boss_health_bar_path: NodePath

@onready var room_manager: RoomManager = get_node(
	room_manager_path
) as RoomManager
@onready var boss_panel: Control = get_node(boss_panel_path) as Control
@onready var boss_name_label: Label = get_node(
	boss_name_label_path
) as Label
@onready var boss_health_bar: ProgressBar = get_node(
	boss_health_bar_path
) as ProgressBar

var current_boss: BossController


func _ready() -> void:
	boss_panel.visible = false
	room_manager.room_changed.connect(_on_room_changed)
	call_deferred("_bind_current_room_boss")


func _on_room_changed(_room_data: RoomData, _room_index: int) -> void:
	call_deferred("_bind_current_room_boss")


func _bind_current_room_boss() -> void:
	current_boss = null
	if room_manager.current_room == null:
		boss_panel.visible = false
		return
	for node in get_tree().get_nodes_in_group(&"room_enemies"):
		if (
			node is BossController
			and room_manager.current_room.is_ancestor_of(node)
		):
			current_boss = node as BossController
			break
	if current_boss == null:
		boss_panel.visible = false
		return

	var data := current_boss.enemy_data as BossData
	boss_name_label.text = (
		data.display_name if data != null else "未知首领"
	)
	current_boss.health_component.health_changed.connect(
		_update_health
	)
	current_boss.health_component.died.connect(_on_boss_died)
	_update_health(
		current_boss.health_component.current_health,
		current_boss.health_component.max_health
	)
	boss_panel.visible = true


func _update_health(current: float, maximum: float) -> void:
	boss_health_bar.max_value = maximum
	boss_health_bar.value = current


func _on_boss_died(_source: Node) -> void:
	boss_panel.visible = false
