class_name VitalsPortrait
extends Control

@export var portrait_texture: Texture2D:
	set(value):
		portrait_texture = value
		if is_node_ready():
			portrait.texture = value

@onready var portrait: TextureRect = $Portrait


func _ready() -> void:
	portrait.texture = portrait_texture


func set_portrait(texture: Texture2D) -> void:
	portrait_texture = texture
