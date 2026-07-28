class_name HubCodexPanel
extends PanelContainer

@export var gene_pool: GeneRewardPoolData
@export var save_path := "user://gene_codex.cfg"
@export_node_path("Label") var count_label_path: NodePath
@export_node_path("RichTextLabel") var entries_path: NodePath

@onready var count_label: Label = get_node(
	count_label_path
) as Label
@onready var entries: RichTextLabel = get_node(
	entries_path
) as RichTextLabel


func _ready() -> void:
	refresh()


func refresh() -> void:
	var seen_ids := _load_seen_ids()
	var genes: Array[GeneData] = []
	if gene_pool != null:
		genes.assign(gene_pool.genes)
	genes.sort_custom(
		func(a: GeneData, b: GeneData) -> bool:
			if a.category != b.category:
				return a.category < b.category
			return a.display_name < b.display_name
	)
	count_label.text = "已见 %d / %d" % [
		seen_ids.size(),
		genes.size(),
	]
	var lines := PackedStringArray()
	for gene in genes:
		if gene == null:
			continue
		if seen_ids.has(gene.id):
			lines.append(
				"[color=%s]◆ %s[/color]\n  %s"
				% [
					gene.get_rarity_color_hex(),
					gene.display_name,
					gene.description,
				]
			)
		else:
			lines.append(
				"[color=#61706f]◇ 未记录基因 · 首次见到后解锁[/color]"
			)
	entries.text = "\n\n".join(lines)


func _load_seen_ids() -> Dictionary:
	var result: Dictionary = {}
	var config := ConfigFile.new()
	if config.load(save_path) != OK:
		return result
	var stored_ids: PackedStringArray = config.get_value(
		"codex",
		"seen_gene_ids",
		PackedStringArray()
	)
	for stored_id in stored_ids:
		result[StringName(stored_id)] = true
	return result
