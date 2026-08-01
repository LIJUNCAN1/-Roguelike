class_name ItemPickupFeedback
extends Node2D

@export_node_path("Node") var relic_manager_path: NodePath
@export_node_path("Node2D") var character_visual_path: NodePath
@export_range(0.2, 5.0, 0.1) var display_duration := 1.8

@onready var relic_manager: RelicManager = get_node(
	relic_manager_path
) as RelicManager
@onready var character_visual: Node2D = get_node_or_null(
	character_visual_path
) as Node2D
@onready var icon: Sprite2D = $Icon

var active_tween: Tween


func _ready() -> void:
	icon.visible = false
	relic_manager.relic_added.connect(show_item)


func show_item(item: RelicData) -> void:
	if item == null or item.icon == null:
		return
	if active_tween != null:
		active_tween.kill()
	icon.texture = item.icon
	icon.position = Vector2(0, -34)
	icon.scale = Vector2.ONE * 2.2
	icon.modulate = Color.WHITE
	icon.visible = true
	if (
		character_visual != null
		and character_visual.has_method("play_use_item_or_skill")
	):
		character_visual.call("play_use_item_or_skill")
	active_tween = create_tween().set_parallel(true)
	active_tween.tween_property(
		icon,
		"position:y",
		-46.0,
		display_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(
		icon,
		"modulate:a",
		0.0,
		display_duration * 0.45
	).set_delay(display_duration * 0.55)
	active_tween.chain().tween_callback(_hide_icon)


func _hide_icon() -> void:
	icon.visible = false
