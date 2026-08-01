class_name RoomCameraController
extends Camera2D

@export_node_path("Node2D") var target_path: NodePath

@onready var target: Node2D = get_node_or_null(target_path) as Node2D


func _ready() -> void:
	position_smoothing_enabled = false
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS


func _physics_process(_delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	global_position = target.global_position.round()


func configure_room(bounds: Rect2, new_target: Node2D = null) -> void:
	if new_target != null:
		target = new_target
	limit_left = roundi(bounds.position.x)
	limit_top = roundi(bounds.position.y)
	limit_right = roundi(bounds.end.x)
	limit_bottom = roundi(bounds.end.y)
	reset_smoothing()
	if target != null:
		global_position = target.global_position.round()
