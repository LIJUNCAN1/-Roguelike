class_name MetaUpgradePanel
extends PanelContainer

@export_node_path("Label") var currency_label_path: NodePath
@export_node_path("VBoxContainer") var upgrade_list_path: NodePath

@onready var currency_label: Label = get_node(
	currency_label_path
) as Label
@onready var upgrade_list: VBoxContainer = get_node(
	upgrade_list_path
) as VBoxContainer
@onready var meta_progression := get_node(
	"/root/MetaProgression"
) as MetaProgressionManager


func _ready() -> void:
	meta_progression.currency_changed.connect(
		func(_currency: int) -> void: refresh()
	)
	meta_progression.upgrade_changed.connect(
		func(_upgrade: MetaUpgradeData, _level: int) -> void:
			refresh()
	)
	refresh()


func refresh() -> void:
	currency_label.text = "进化质：%d" % meta_progression.currency
	for child in upgrade_list.get_children():
		child.queue_free()
	if meta_progression.catalog == null:
		return
	for upgrade in meta_progression.catalog.upgrades:
		if upgrade == null:
			continue
		var button := Button.new()
		var level := meta_progression.get_upgrade_level(upgrade.id)
		var is_max := level >= upgrade.max_level
		button.text = "%s  Lv.%d/%d  %s\n%s" % [
			upgrade.display_name,
			level,
			upgrade.max_level,
			"已满级" if is_max else "消耗 %d" % (
				meta_progression.get_upgrade_cost(upgrade.id)
			),
			upgrade.description,
		]
		button.disabled = (
			is_max
			or meta_progression.currency
			< meta_progression.get_upgrade_cost(upgrade.id)
		)
		button.custom_minimum_size = Vector2(0, 48)
		button.pressed.connect(
			func() -> void:
				meta_progression.purchase_upgrade(upgrade.id)
		)
		upgrade_list.add_child(button)
