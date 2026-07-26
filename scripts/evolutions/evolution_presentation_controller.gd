class_name EvolutionPresentationController
extends Node

@export_node_path("Node") var evolution_system_path: NodePath
@export_node_path("Node") var player_health_path: NodePath
@export_node_path("Node2D") var player_visuals_path: NodePath
@export_node_path("Node2D") var effects_container_path: NodePath
@export_node_path("ColorRect") var flash_path: NodePath
@export_node_path("Label") var banner_path: NodePath
@export_node_path("Node") var screen_shake_path: NodePath

@onready var evolution_system: EvolutionSystem = get_node(
	evolution_system_path
) as EvolutionSystem
@onready var player_health: HealthComponent = get_node(
	player_health_path
) as HealthComponent
@onready var player_visuals: Node2D = get_node(
	player_visuals_path
) as Node2D
@onready var effects_container: Node2D = get_node(
	effects_container_path
) as Node2D
@onready var flash: ColorRect = get_node(flash_path) as ColorRect
@onready var banner: Label = get_node(banner_path) as Label
@onready var screen_shake: ScreenShakeComponent = get_node(
	screen_shake_path
) as ScreenShakeComponent

var active_ui_tween: Tween
var active_form_tween: Tween


func _ready() -> void:
	flash.visible = false
	banner.visible = false
	evolution_system.evolution_changed.connect(_on_evolution_changed)


func _on_evolution_changed(
	previous: EvolutionData,
	current: EvolutionData
) -> void:
	if (
		previous == null
		or current == null
		or current.presentation_data == null
	):
		return
	var data := current.presentation_data
	player_health.grant_invulnerability(data.invulnerability_duration)
	screen_shake.add_trauma(data.shake_strength)
	_show_burst(data)
	_animate_form(data)
	_show_ui(previous, current, data)


func _show_burst(data: EvolutionPresentationData) -> void:
	var burst := EvolutionBurstEffect.new()
	burst.name = "EvolutionBurst"
	effects_container.add_child(burst)
	burst.global_position = player_visuals.global_position
	burst.configure(data)


func _animate_form(data: EvolutionPresentationData) -> void:
	if active_form_tween != null and active_form_tween.is_valid():
		active_form_tween.kill()
	player_visuals.scale = Vector2.ONE * 0.55
	player_visuals.modulate = Color(
		data.accent_color.r,
		data.accent_color.g,
		data.accent_color.b,
		0.35
	)
	active_form_tween = create_tween()
	active_form_tween.set_parallel(true)
	active_form_tween.tween_property(
		player_visuals,
		"scale",
		Vector2.ONE * data.pulse_scale,
		data.transformation_duration * 0.55
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	active_form_tween.tween_property(
		player_visuals,
		"modulate",
		Color.WHITE,
		data.transformation_duration * 0.55
	)
	active_form_tween.set_parallel(false)
	active_form_tween.tween_property(
		player_visuals,
		"scale",
		Vector2.ONE,
		data.transformation_duration * 0.45
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _show_ui(
	previous: EvolutionData,
	current: EvolutionData,
	data: EvolutionPresentationData
) -> void:
	if active_ui_tween != null and active_ui_tween.is_valid():
		active_ui_tween.kill()
	flash.color = data.accent_color
	flash.color.a = 0.0
	flash.visible = true
	banner.text = "生命进化\n%s  →  %s\n%s" % [
		previous.display_name,
		current.display_name,
		data.attack_change_text,
	]
	banner.modulate = Color(
		data.accent_color.r,
		data.accent_color.g,
		data.accent_color.b,
		0.0
	)
	banner.visible = true
	active_ui_tween = create_tween()
	active_ui_tween.set_parallel(true)
	active_ui_tween.tween_property(
		flash,
		"color:a",
		0.42,
		0.1
	)
	active_ui_tween.tween_property(
		banner,
		"modulate:a",
		1.0,
		0.18
	)
	active_ui_tween.set_parallel(false)
	active_ui_tween.tween_property(
		flash,
		"color:a",
		0.0,
		0.24
	)
	active_ui_tween.tween_interval(
		maxf(data.transformation_duration, 0.5)
	)
	active_ui_tween.set_parallel(true)
	active_ui_tween.tween_property(
		banner,
		"modulate:a",
		0.0,
		0.35
	)
	active_ui_tween.set_parallel(false)
	active_ui_tween.tween_callback(_hide_ui)


func _hide_ui() -> void:
	flash.visible = false
	banner.visible = false
