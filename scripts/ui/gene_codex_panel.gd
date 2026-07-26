class_name GeneCodexPanel
extends CanvasLayer

@export_node_path("Node") var codex_manager_path: NodePath
@export_node_path("Node") var gene_manager_path: NodePath

@onready var codex_manager: GeneCodexManager = get_node(
	codex_manager_path
) as GeneCodexManager
@onready var gene_manager: GeneManager = get_node(
	gene_manager_path
) as GeneManager
@onready var panel: Control = $Dimmer
@onready var count_label: Label = $Dimmer/Panel/Margin/Content/Count
@onready var entries: RichTextLabel = (
	$Dimmer/Panel/Margin/Content/Entries
)

var paused_before_open: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	codex_manager.codex_changed.connect(_refresh)
	gene_manager.genes_changed.connect(_refresh)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_gene_codex"):
		toggle()
		get_viewport().set_input_as_handled()
	elif panel.visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	if panel.visible:
		close()
	else:
		open()


func open() -> void:
	paused_before_open = get_tree().paused
	panel.visible = true
	_refresh()
	get_tree().paused = true


func close() -> void:
	panel.visible = false
	get_tree().paused = paused_before_open


func is_open() -> bool:
	return panel.visible


func _refresh() -> void:
	var all_genes := codex_manager.get_all_genes()
	all_genes.sort_custom(
		func(a: GeneData, b: GeneData) -> bool:
			if a.series_name == b.series_name:
				return a.display_name < b.display_name
			return a.series_name < b.series_name
	)
	count_label.text = "已见 %d / %d · 获得 %d" % [
		codex_manager.get_seen_count(),
		all_genes.size(),
		gene_manager.get_active_genes().size(),
	]
	var text := ""
	var current_series: StringName
	for gene in all_genes:
		if gene == null:
			continue
		if gene.series_id != current_series:
			current_series = gene.series_id
			text += "\n[color=#78e8ae][font_size=15]%s[/font_size][/color]\n" % (
				gene.series_name if not gene.series_name.is_empty()
				else "未分类系列"
			)
		var owned := gene_manager.has_gene(gene.id)
		if codex_manager.is_gene_seen(gene.id):
			text += "[color=%s]◆ %s%s[/color]\n  %s\n" % [
				"#fff08a" if owned else "#d8e8e4",
				gene.display_name,
				"  [已获得]" if owned else "",
				gene.description,
			]
		else:
			text += "[color=#61706f]◇ 未记录基因\n  首次见到后解锁描述[/color]\n"
	entries.text = text.strip_edges()
