class_name PixelVitalsPresenter
extends Control

@export_node_path("Node") var health_component_path: NodePath
@export_node_path("Node") var progression_path: NodePath
@export_node_path("ProgressBar") var health_bar_path: NodePath
@export_node_path("ProgressBar") var experience_bar_path: NodePath
@export_node_path("Label") var health_text_path: NodePath
@export_node_path("Label") var experience_text_path: NodePath

@onready var health_component: HealthComponent = get_node(
	health_component_path
) as HealthComponent
@onready var progression: RunProgression = get_node(
	progression_path
) as RunProgression
@onready var health_bar: ProgressBar = get_node(
	health_bar_path
) as ProgressBar
@onready var experience_bar: ProgressBar = get_node(
	experience_bar_path
) as ProgressBar
@onready var health_text: Label = get_node(
	health_text_path
) as Label
@onready var experience_text: Label = get_node(
	experience_text_path
) as Label


func _ready() -> void:
	health_component.health_changed.connect(_update_health)
	progression.experience_changed.connect(_update_experience)
	_update_health(
		health_component.current_health,
		health_component.max_health
	)
	_update_experience(
		progression.current_experience,
		progression.get_experience_to_next_level(),
		progression.level
	)


func _update_health(current: float, maximum: float) -> void:
	health_bar.max_value = maxf(maximum, 1.0)
	health_bar.value = clampf(current, 0.0, maximum)
	health_text.text = "%d/%d" % [
		roundi(current),
		roundi(maximum),
	]


func _update_experience(
	current: int,
	required: int,
	_level: int
) -> void:
	experience_bar.max_value = maxi(required, 1)
	experience_bar.value = clampi(current, 0, required)
	experience_text.text = "%d/%d" % [current, required]
