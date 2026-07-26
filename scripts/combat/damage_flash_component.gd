class_name DamageFlashComponent
extends Node

@export_node_path("Node") var health_component_path: NodePath
@export_node_path("CanvasItem") var visual_root_path: NodePath
@export var flash_color: Color = Color(1.0, 0.28, 0.32, 1.0)
@export_range(0.01, 2.0, 0.01, "or_greater")
var flash_duration: float = 0.18

@onready var health_component: HealthComponent = get_node(
	health_component_path
) as HealthComponent
@onready var visual_root: CanvasItem = get_node(
	visual_root_path
) as CanvasItem

var rest_modulate: Color
var flash_tween: Tween


func _ready() -> void:
	rest_modulate = visual_root.modulate
	health_component.damaged.connect(_on_damaged)


func _on_damaged(
	_amount: float,
	_current_health: float,
	_source: Node
) -> void:
	if flash_tween != null and flash_tween.is_valid():
		flash_tween.kill()
	visual_root.modulate = flash_color
	flash_tween = create_tween()
	flash_tween.tween_property(
		visual_root,
		"modulate",
		rest_modulate,
		flash_duration
	)
