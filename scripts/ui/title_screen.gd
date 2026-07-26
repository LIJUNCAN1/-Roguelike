class_name TitleScreen
extends Node2D

@export_file("*.tscn") var game_scene_path: String = (
	"res://scenes/main/main.tscn"
)

@onready var start_button: Button = $Interface/Menu/Content/StartButton
@onready var meta_button: Button = $Interface/Menu/Content/MetaButton
@onready var codex_button: Button = $Interface/Menu/Content/CodexButton
@onready var quit_button: Button = $Interface/Menu/Content/QuitButton
@onready var menu: Control = $Interface/Menu
@onready var meta_panel: Control = $Interface/MetaUpgradePanel
@onready var codex_panel: Control = $Interface/GeneCodexPanel
@onready var meta_back_button: Button = (
	$Interface/MetaUpgradePanel/Content/BackButton
)
@onready var codex_back_button: Button = (
	$Interface/GeneCodexPanel/Content/BackButton
)


func _ready() -> void:
	get_tree().paused = false
	start_button.pressed.connect(start_game)
	meta_button.pressed.connect(open_meta_upgrades)
	codex_button.pressed.connect(open_gene_codex)
	quit_button.pressed.connect(quit_game)
	meta_back_button.pressed.connect(close_submenu)
	codex_back_button.pressed.connect(close_submenu)
	close_submenu()
	start_button.grab_focus()


func start_game() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(game_scene_path)


func quit_game() -> void:
	get_tree().quit()


func open_meta_upgrades() -> void:
	menu.visible = false
	codex_panel.visible = false
	meta_panel.visible = true


func open_gene_codex() -> void:
	menu.visible = false
	meta_panel.visible = false
	codex_panel.visible = true


func close_submenu() -> void:
	meta_panel.visible = false
	codex_panel.visible = false
	menu.visible = true
