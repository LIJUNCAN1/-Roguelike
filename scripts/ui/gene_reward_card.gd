class_name GeneRewardCard
extends Button

@onready var choice_label: Label = $Margin/Content/Header/Choice
@onready var rarity_label: Label = $Margin/Content/Header/Rarity
@onready var sigil_label: Label = $Margin/Content/Sigil
@onready var name_label: Label = $Margin/Content/Name
@onready var category_label: Label = $Margin/Content/Category
@onready var level_label: Label = $Margin/Content/Level
@onready var description_label: Label = $Margin/Content/Description
@onready var effect_label: Label = $Margin/Content/Effect
@onready var relation_label: Label = $Margin/Content/Relation

var gene_data: GeneData


func configure(
	gene: GeneData,
	choice_index: int,
	related_owned: Array[GeneData] = []
) -> void:
	gene_data = gene
	if gene == null:
		visible = false
		return

	visible = true
	disabled = false
	choice_label.text = "%d" % (choice_index + 1)
	rarity_label.text = gene.get_rarity_name()
	sigil_label.text = gene.display_name.substr(0, 1)
	name_label.text = gene.display_name
	category_label.text = gene.get_category_name()
	level_label.text = "未拥有  ▶  获得"
	description_label.text = gene.description
	effect_label.text = (
		gene.get_tags_text()
		if not gene.tags.is_empty()
		else "改变你的进化方向"
	)
	relation_label.text = _get_relation_text(gene, related_owned)

	var rarity_color := Color.from_string(
		gene.get_rarity_color_hex(),
		Color.WHITE
	)
	rarity_label.add_theme_color_override("font_color", rarity_color)
	sigil_label.add_theme_color_override("font_color", rarity_color)
	name_label.add_theme_color_override("font_color", rarity_color)
	tooltip_text = "%s：%s" % [gene.display_name, gene.description]
	set_meta("gene_id", gene.id)


func _get_relation_text(
	gene: GeneData,
	related_owned: Array[GeneData]
) -> String:
	if related_owned.is_empty():
		if gene.series_name.is_empty():
			return "新系列"
		return "%s · 尚无同系基因" % gene.series_name

	var names := PackedStringArray()
	for related_gene in related_owned:
		names.append(related_gene.display_name)
	return "同系已有：%s" % "、".join(names)
