class_name AreaIntroPresenter
extends Control

@export_node_path("Node") var room_manager_path: NodePath
@export_node_path("Label") var title_label_path: NodePath
@export_node_path("Label") var objective_label_path: NodePath
@export var fade_in_duration: float = 0.55
@export var hold_duration: float = 1.35
@export var fade_out_duration: float = 0.8

@onready var room_manager: RoomManager = get_node(
	room_manager_path
) as RoomManager
@onready var title_label: Label = get_node(title_label_path) as Label
@onready var objective_label: Label = get_node(
	objective_label_path
) as Label

var last_region_id: StringName
var intro_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 0.0
	visible = false
	room_manager.room_changed.connect(_on_room_changed)
	call_deferred("_show_current_region")


func _on_room_changed(room_data: RoomData, _room_index: int) -> void:
	if room_data != null:
		_show_region(room_data.region)


func _show_current_region() -> void:
	var room_data := room_manager.get_current_room_data()
	if room_data != null:
		_show_region(room_data.region)


func _show_region(region: RegionData) -> void:
	if region == null or region.id == last_region_id:
		return
	last_region_id = region.id
	title_label.text = region.display_name
	objective_label.text = region.entry_objective
	title_label.add_theme_color_override("font_color", region.accent_color)
	if intro_tween != null:
		intro_tween.kill()
	visible = true
	modulate.a = 0.0
	intro_tween = create_tween()
	intro_tween.tween_property(
		self,
		"modulate:a",
		1.0,
		fade_in_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	intro_tween.tween_interval(hold_duration)
	intro_tween.tween_property(
		self,
		"modulate:a",
		0.0,
		fade_out_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	intro_tween.tween_callback(func() -> void: visible = false)
