class_name TitleScreen
extends Node2D

@export_file("*.tscn") var game_scene_path: String = (
	"res://scenes/main/main.tscn"
)

@onready var start_button: Button = $Interface/Menu/Content/StartButton
@onready var quit_button: Button = $Interface/Menu/Content/QuitButton


func _ready() -> void:
	get_tree().paused = false
	start_button.pressed.connect(start_game)
	quit_button.pressed.connect(quit_game)
	start_button.grab_focus()


func start_game() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(game_scene_path)


func quit_game() -> void:
	get_tree().quit()
