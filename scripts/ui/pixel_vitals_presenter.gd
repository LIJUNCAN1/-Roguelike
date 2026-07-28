class_name PixelVitalsPresenter
extends Control

@export_node_path("Node") var health_component_path: NodePath
@export_node_path("Node") var progression_path: NodePath
@export_node_path("ProgressBar") var health_bar_path: NodePath
@export_node_path("ProgressBar") var experience_bar_path: NodePath
@export_node_path("Label") var health_text_path: NodePath
@export_node_path("Label") var experience_text_path: NodePath
@export_node_path("Label") var level_text_path: NodePath

@export_group("Adaptive Colors")
@export var health_full_color := Color(0.4, 0.012, 0.025, 1.0)
@export var health_low_color := Color(1.0, 0.18, 0.1, 1.0)
@export var experience_full_color := Color(0.08, 0.78, 0.72, 1.0)
@export var experience_low_color := Color(0.02, 0.3, 0.32, 1.0)

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
@onready var level_text: Label = get_node(level_text_path) as Label

var health_fill_style: StyleBoxFlat
var experience_fill_style: StyleBoxFlat


func _ready() -> void:
	health_fill_style = (
		health_bar.get_theme_stylebox("fill").duplicate()
		as StyleBoxFlat
	)
	experience_fill_style = (
		experience_bar.get_theme_stylebox("fill").duplicate()
		as StyleBoxFlat
	)
	health_bar.add_theme_stylebox_override("fill", health_fill_style)
	experience_bar.add_theme_stylebox_override(
		"fill",
		experience_fill_style
	)
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
	var health_ratio := clampf(current / maxf(maximum, 1.0), 0.0, 1.0)
	health_fill_style.bg_color = health_low_color.lerp(
		health_full_color,
		health_ratio
	)
	health_text.text = "%d/%d" % [
		roundi(current),
		roundi(maximum),
	]


func _update_experience(
	current: int,
	required: int,
	level: int
) -> void:
	experience_bar.max_value = maxi(required, 1)
	experience_bar.value = clampi(current, 0, required)
	var experience_ratio := clampf(
		float(current) / float(maxi(required, 1)),
		0.0,
		1.0
	)
	experience_fill_style.bg_color = experience_low_color.lerp(
		experience_full_color,
		experience_ratio
	)
	level_text.text = "Lv.%d" % level
	experience_text.text = ""
