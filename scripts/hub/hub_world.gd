class_name HubWorld
extends Node2D

const REFERENCE_PATH := "res://reference/hub_map_reference.png"

@export_file("*.tscn") var run_scene_path := (
	"res://scenes/main/main.tscn"
)
@export var scene_transitions_enabled := true
@export var facility_panels_enabled := true
@export var camera_intro_enabled := true
@export var camera_intro_start_zoom := Vector2(2.0, 2.0)
@export var camera_gameplay_zoom := Vector2(1.45, 1.45)
@export var camera_pixel_stabilization_enabled := true
@export_range(1.0, 2.0, 0.05) var hub_player_visual_multiplier := 1.35
@export_range(0.1, 3.0, 0.05)
var camera_intro_duration := 1.15

@onready var reference_layer: Node2D = $ReferenceLayer
@onready var reference_image: Sprite2D = $ReferenceLayer/ReferenceImage
@onready var player_spawn: Marker2D = $Markers/PlayerSpawn
@onready var camera_top_left: Marker2D = $Markers/CameraTopLeft
@onready var camera_bottom_right: Marker2D = (
	$Markers/CameraBottomRight
)
@onready var player: CharacterBody2D = $YSortRoot/Player
@onready var camera: Camera2D = $YSortRoot/Player/Camera2D
@onready var interaction_prompt: InteractionPrompt = (
	$HUDLayer/InteractionPrompt
)
@onready var core_visual: Node2D = (
	$YSortRoot/Stations/CoreAltar/CoreVisual
)
@onready var campfire_flame: Polygon2D = (
	$YSortRoot/Stations/RestCampfire/Flame
)
@onready var meta_upgrade_dimmer: Control = (
	$HUDLayer/MetaUpgradeDimmer
)
@onready var meta_upgrade_panel: MetaUpgradePanel = (
	$HUDLayer/MetaUpgradeDimmer/MetaUpgradePanel
)
@onready var meta_back_button: Button = (
	$HUDLayer/MetaUpgradeDimmer/MetaUpgradePanel/Content/BackButton
)
@onready var codex_dimmer: Control = $HUDLayer/CodexDimmer
@onready var codex_panel: HubCodexPanel = (
	$HUDLayer/CodexDimmer/CodexPanel
)
@onready var codex_back_button: Button = (
	$HUDLayer/CodexDimmer/CodexPanel/Content/BackButton
)

var focused_interactable: Interactable
var last_interaction_id: StringName
var _camera_intro_tween: Tween


func _ready() -> void:
	_load_reference_if_available()
	reference_layer.visible = false
	player.global_position = player_spawn.global_position
	_apply_hub_player_visual_scale()
	_configure_camera_limits()
	_start_camera_intro()
	_connect_interactables()
	meta_back_button.pressed.connect(_close_facility_panels)
	codex_back_button.pressed.connect(_close_facility_panels)
	meta_upgrade_dimmer.visible = false
	codex_dimmer.visible = false
	_start_ambient_animation()


func _apply_hub_player_visual_scale() -> void:
	var visual_root := player.get_node_or_null("Visuals") as Node2D
	if visual_root != null:
		visual_root.scale = Vector2.ONE * hub_player_visual_multiplier


func _process(_delta: float) -> void:
	_stabilize_camera_position()


func _load_reference_if_available() -> void:
	if not ResourceLoader.exists(REFERENCE_PATH):
		return
	reference_image.texture = load(REFERENCE_PATH) as Texture2D


func _configure_camera_limits() -> void:
	camera.limit_left = roundi(camera_top_left.global_position.x)
	camera.limit_top = roundi(camera_top_left.global_position.y)
	camera.limit_right = roundi(
		camera_bottom_right.global_position.x
	)
	camera.limit_bottom = roundi(
		camera_bottom_right.global_position.y
	)
	camera.position = Vector2.ZERO
	camera.position_smoothing_enabled = false
	camera.enabled = true


func _stabilize_camera_position() -> void:
	if (
		not camera_pixel_stabilization_enabled
		or camera == null
		or player == null
		or camera.zoom.x <= 0.0
		or camera.zoom.y <= 0.0
	):
		return
	var target := player.global_position
	camera.global_position = Vector2(
		roundf(target.x * camera.zoom.x) / camera.zoom.x,
		roundf(target.y * camera.zoom.y) / camera.zoom.y
	)


func _start_camera_intro() -> void:
	if not camera_intro_enabled or DisplayServer.get_name() == "headless":
		camera.zoom = camera_gameplay_zoom
		return
	camera.zoom = camera_intro_start_zoom
	_camera_intro_tween = create_tween()
	_camera_intro_tween.tween_interval(0.2)
	_camera_intro_tween.tween_property(
		camera,
		"zoom",
		camera_gameplay_zoom,
		camera_intro_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _connect_interactables() -> void:
	for node in get_tree().get_nodes_in_group(
		&"hub_interactables"
	):
		if not is_ancestor_of(node) or not node is Interactable:
			continue
		var interactable := node as Interactable
		interactable.focus_entered.connect(
			_on_interactable_focused
		)
		interactable.focus_exited.connect(
			_on_interactable_unfocused
		)
		interactable.interaction_requested.connect(
			_on_interaction_requested.bind(interactable)
		)


func _on_interactable_focused(
	interactable: Interactable,
	_actor: Node
) -> void:
	focused_interactable = interactable
	interaction_prompt.show_interactable(interactable)


func _on_interactable_unfocused(
	interactable: Interactable,
	_actor: Node
) -> void:
	if focused_interactable != interactable:
		return
	focused_interactable = null
	interaction_prompt.hide_prompt()


func _on_interaction_requested(
	interaction_id: StringName,
	interactable: Interactable
) -> void:
	last_interaction_id = interaction_id
	print(
		"Hub interaction requested: %s (%s)"
		% [interactable.display_name, interaction_id]
	)
	if not facility_panels_enabled:
		return
	match interaction_id:
		&"core_altar":
			if scene_transitions_enabled:
				call_deferred("_start_adventure")
		&"bloodline_shop":
			_open_meta_upgrades()
		&"archive_station":
			_open_codex()


func _start_adventure() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(run_scene_path)


func _open_meta_upgrades() -> void:
	meta_upgrade_panel.refresh()
	meta_upgrade_dimmer.visible = true
	get_tree().paused = true
	meta_back_button.grab_focus()


func _open_codex() -> void:
	codex_panel.refresh()
	codex_dimmer.visible = true
	get_tree().paused = true
	codex_back_button.grab_focus()


func _close_facility_panels() -> void:
	meta_upgrade_dimmer.visible = false
	codex_dimmer.visible = false
	get_tree().paused = false


func _start_ambient_animation() -> void:
	# Facilities remain spatially stable. Ambient motion is provided by the
	# existing lightweight particle emitters only.
	core_visual.scale = Vector2.ONE
	campfire_flame.modulate = Color.WHITE
