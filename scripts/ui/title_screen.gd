class_name TitleScreen
extends Node2D

@export_file("*.tscn") var game_scene_path: String = (
	"res://scenes/main/main.tscn"
)

@onready var start_button: Button = $Interface/Menu/Content/StartButton
@onready var settings_button: Button = $Interface/Menu/Content/SettingsButton
@onready var version_button: Button = $Interface/Menu/Content/VersionButton
@onready var roadmap_button: Button = $Interface/Menu/Content/RoadmapButton
@onready var credits_button: Button = $Interface/Menu/Content/CreditsButton
@onready var codex_button: Button = $Interface/Menu/Content/CodexButton
@onready var quit_button: Button = $Interface/Menu/Content/QuitButton

# Kept as a compatibility alias for the existing smoke test and old callers.
@onready var meta_button: Button = settings_button

@onready var menu: Control = $Interface/Menu
@onready var menu_backdrop: Control = $Interface/MenuBackdrop
@onready var title_image: Control = $Interface/TitleImage
@onready var social_icons: Control = $Interface/SocialIcons
@onready var meta_panel: Control = $Interface/MetaUpgradePanel
@onready var codex_panel: Control = $Interface/GeneCodexPanel
@onready var info_panel: Control = $Interface/GeneralInfoPanel
@onready var info_title: Label = $Interface/GeneralInfoPanel/Margin/Content/Title
@onready var info_body: Label = $Interface/GeneralInfoPanel/Margin/Content/Body
@onready var info_back_button: Button = (
	$Interface/GeneralInfoPanel/Margin/Content/BackButton
)
@onready var meta_back_button: Button = (
	$Interface/MetaUpgradePanel/Content/BackButton
)
@onready var codex_back_button: Button = (
	$Interface/GeneCodexPanel/Content/BackButton
)

var button_tweens: Dictionary = {}


func _ready() -> void:
	get_tree().paused = false
	start_button.pressed.connect(start_game)
	settings_button.pressed.connect(open_settings)
	version_button.pressed.connect(open_version_info)
	roadmap_button.pressed.connect(open_roadmap)
	credits_button.pressed.connect(open_credits)
	codex_button.pressed.connect(open_gene_codex)
	quit_button.pressed.connect(quit_game)
	info_back_button.pressed.connect(close_submenu)
	meta_back_button.pressed.connect(close_submenu)
	codex_back_button.pressed.connect(close_submenu)
	close_submenu()
	call_deferred("prepare_button_animations")
	start_button.grab_focus()


func prepare_button_animations() -> void:
	var buttons: Array[Button] = [
		start_button,
		settings_button,
		version_button,
		roadmap_button,
		credits_button,
		codex_button,
		quit_button,
		info_back_button,
		meta_back_button,
		codex_back_button,
	]
	for child in social_icons.get_children():
		if child is Button:
			buttons.append(child as Button)
	for button in buttons:
		button.pivot_offset = button.size * 0.5
		button.mouse_entered.connect(animate_button.bind(button, true))
		button.mouse_exited.connect(animate_button.bind(button, false))
		button.focus_entered.connect(animate_button.bind(button, true))
		button.focus_exited.connect(animate_button.bind(button, false))


func animate_button(button: Button, is_active: bool) -> void:
	if button_tweens.has(button):
		var previous := button_tweens[button] as Tween
		if previous != null:
			previous.kill()
	var tween := create_tween().set_parallel(true)
	button_tweens[button] = tween
	var target_scale := Vector2(1.045, 1.045) if is_active else Vector2.ONE
	var target_color := Color(1.12, 1.08, 1.18, 1) if is_active else Color.WHITE
	tween.tween_property(button, "scale", target_scale, 0.13).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "modulate", target_color, 0.13).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_OUT)


func start_game() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(game_scene_path)


func quit_game() -> void:
	get_tree().quit()


func open_settings() -> void:
	open_info(
		"设置",
		"显示设置\n"
		+ "• 分辨率：1280 × 720\n"
		+ "• 画面模式：窗口化\n\n"
		+ "音频、按键与更多显示选项将在后续 EA 版本中开放。"
	)


func open_version_info() -> void:
	open_info(
		"版本信息",
		"《原初之种》 Early Access\n"
		+ "当前版本：EA 0.1.0\n"
		+ "开发阶段：核心战斗、基因构筑与冒险循环验证\n\n"
		+ "感谢参与早期版本测试。"
	)


func open_roadmap() -> void:
	open_info(
		"EA 开发规划",
		"近期目标\n"
		+ "• 完善角色、武器与基因平衡\n"
		+ "• 扩充区域事件、首领与进化路线\n"
		+ "• 加入完整音频、设置与存档功能\n"
		+ "• 持续优化 UI、性能和操作反馈"
	)


func open_credits() -> void:
	open_info(
		"制作名单",
		"游戏设计 / 程序 / 美术\n"
		+ "原初之种开发团队\n\n"
		+ "特别感谢\n"
		+ "所有参与测试与提供建议的玩家"
	)


func open_info(title: String, body: String) -> void:
	menu.visible = false
	meta_panel.visible = false
	codex_panel.visible = false
	info_title.text = title
	info_body.text = body
	info_panel.visible = true
	set_main_decoration_visible(false)
	info_back_button.grab_focus()


# Preserved for the existing progression panel and automated test coverage.
func open_meta_upgrades() -> void:
	menu.visible = false
	info_panel.visible = false
	codex_panel.visible = false
	meta_panel.visible = true
	set_main_decoration_visible(false)


func open_gene_codex() -> void:
	menu.visible = false
	info_panel.visible = false
	meta_panel.visible = false
	codex_panel.visible = true
	set_main_decoration_visible(false)


func close_submenu() -> void:
	info_panel.visible = false
	meta_panel.visible = false
	codex_panel.visible = false
	menu.visible = true
	set_main_decoration_visible(true)


func set_main_decoration_visible(is_visible: bool) -> void:
	title_image.visible = is_visible
	menu_backdrop.visible = is_visible
	social_icons.visible = is_visible
