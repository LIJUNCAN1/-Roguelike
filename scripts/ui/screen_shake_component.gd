class_name ScreenShakeComponent
extends Node

@export_node_path("Node") var player_health_path: NodePath
@export_node_path("Camera2D") var camera_path: NodePath
@export_range(0.0, 32.0, 0.5, "or_greater")
var hit_strength: float = 5.0
@export_range(0.1, 30.0, 0.1, "or_greater")
var decay_speed: float = 12.0

@onready var player_health: HealthComponent = get_node(
	player_health_path
) as HealthComponent
@onready var camera: Camera2D = get_node(camera_path) as Camera2D

var trauma: float = 0.0
var shake_time: float = 0.0


func _ready() -> void:
	player_health.damaged.connect(_on_player_damaged)


func _process(delta: float) -> void:
	trauma = maxf(trauma - decay_speed * delta, 0.0)
	if trauma <= 0.0:
		camera.offset = Vector2.ZERO
		return
	shake_time += delta * 52.0
	camera.offset = Vector2(
		sin(shake_time * 1.7),
		cos(shake_time * 2.3)
	) * trauma


func add_trauma(strength: float) -> void:
	trauma = maxf(trauma, strength)


func _on_player_damaged(
	_amount: float,
	_current_health: float,
	_source: Node
) -> void:
	add_trauma(hit_strength)
