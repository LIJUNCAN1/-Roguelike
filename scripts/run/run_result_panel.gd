class_name RunResultPanel
extends CanvasLayer

@onready var title_label: Label = $Dimmer/Panel/Margin/Content/Title
@onready var summary_label: Label = $Dimmer/Panel/Margin/Content/Summary


func _ready() -> void:
	hide_result()


func show_result(
	victory: bool,
	route_seed: int,
	gene_count: int,
	meta_reward: int = 0,
	meta_total: int = 0
) -> void:
	if victory:
		title_label.text = "进化完成"
		title_label.modulate = Color(0.45, 1.0, 0.68, 1.0)
		summary_label.text = "Boss 已被击败\n本次获得 %d 段基因\n进化质 +%d（持有 %d）\n路线种子：%d" % [
			gene_count,
			meta_reward,
			meta_total,
			route_seed,
		]
	else:
		title_label.text = "生命体崩解"
		title_label.modulate = Color(1.0, 0.32, 0.25, 1.0)
		summary_label.text = "本次进化未能延续\n已获得 %d 段基因\n进化质 +%d（持有 %d）\n路线种子：%d" % [
			gene_count,
			meta_reward,
			meta_total,
			route_seed,
		]
	visible = true


func hide_result() -> void:
	visible = false
