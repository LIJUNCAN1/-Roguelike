class_name FusionMorphPresenter
extends Node2D

@export_node_path("Node") var fusion_manager_path: NodePath

@onready var fusion_manager: FusionManager = get_node(
	fusion_manager_path
) as FusionManager

var active_fusion: FusionData
var pulse_time: float = 0.0


func _ready() -> void:
	fusion_manager.fusions_changed.connect(_refresh)
	_refresh()


func _process(delta: float) -> void:
	if active_fusion == null:
		return
	pulse_time += delta
	queue_redraw()


func _refresh() -> void:
	active_fusion = null
	for fusion in fusion_manager.get_active_fusions():
		if (
			active_fusion == null
			or fusion.presentation_priority
			> active_fusion.presentation_priority
		):
			active_fusion = fusion
	pulse_time = 0.0
	queue_redraw()


func _draw() -> void:
	if active_fusion == null:
		return
	var pulse := (sin(pulse_time * 4.0) + 1.0) * 0.5
	var color := active_fusion.form_color
	color.a = 0.72 + pulse * 0.2
	var size := active_fusion.form_scale
	match active_fusion.form_style:
		FusionData.FormStyle.HORNS:
			_draw_horns(color, size)
		FusionData.FormStyle.WINGS:
			_draw_wings(color, size)
		FusionData.FormStyle.TENTACLES:
			_draw_tentacles(color, size)
		FusionData.FormStyle.ARMOR:
			_draw_armor(color, size)
		_:
			draw_arc(
				Vector2.ZERO,
				13.0 * size + pulse * 2.0,
				0.0,
				TAU,
				32,
				color,
				2.0
			)


func _draw_horns(color: Color, size: float) -> void:
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-7, -6), Vector2(-13, -18) * size,
			Vector2(-2, -9),
		]),
		color
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(7, -6), Vector2(13, -18) * size,
			Vector2(2, -9),
		]),
		color
	)


func _draw_wings(color: Color, size: float) -> void:
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-6, -3), Vector2(-22, -12) * size,
			Vector2(-17, 7) * size, Vector2(-5, 4),
		]),
		color
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(6, -3), Vector2(22, -12) * size,
			Vector2(17, 7) * size, Vector2(5, 4),
		]),
		color
	)


func _draw_tentacles(color: Color, size: float) -> void:
	for angle in [0.35, 1.2, 1.95, 2.8]:
		var direction := Vector2.RIGHT.rotated(float(angle) + pulse_time * 0.12)
		draw_line(
			direction * 7.0,
			direction * 19.0 * size,
			color,
			3.0
		)


func _draw_armor(color: Color, size: float) -> void:
	var points := PackedVector2Array()
	for index in 8:
		points.append(
			Vector2.RIGHT.rotated(index * TAU / 8.0)
			* (12.0 if index % 2 == 0 else 9.0)
			* size
		)
	draw_polyline(points + PackedVector2Array([points[0]]), color, 2.5)
