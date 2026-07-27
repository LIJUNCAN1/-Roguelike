class_name SocialLinkButton
extends Button

@export var social_name: String = "社交链接"
@export var icon_texture: Texture2D
@export var link_url: String = ""


func _ready() -> void:
	add_to_group("social_icon_buttons")
	icon = icon_texture
	tooltip_text = social_name
	pressed.connect(open_link)


func open_link() -> void:
	if link_url.strip_edges().is_empty():
		return
	OS.shell_open(link_url)
