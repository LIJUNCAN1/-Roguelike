extends Node

@export var debug_hotkeys_enabled: bool = false
@export var dragon_heart: RelicData
@export_node_path("Node") var relic_manager_path: NodePath

@onready var relic_manager: RelicManager = get_node(
	relic_manager_path
) as RelicManager
func _unhandled_input(event: InputEvent) -> void:
	if not debug_hotkeys_enabled:
		return
	if not event.is_action_pressed("toggle_dragon_heart"):
		return
	if relic_manager.has_relic(dragon_heart.id):
		relic_manager.remove_relic(dragon_heart.id)
	else:
		relic_manager.add_relic(dragon_heart)
	get_viewport().set_input_as_handled()
