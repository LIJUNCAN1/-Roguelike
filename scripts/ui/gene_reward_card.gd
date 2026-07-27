class_name GeneRewardCard
extends Button

@onready var choice_label: Label = $Margin/Content/Header/Choice
@onready var rarity_label: Label = $Margin/Content/Header/Rarity
@onready var icon_stage: Panel = $Margin/Content/IconStage
@onready var diamond_label: Label = $Margin/Content/IconStage/Diamond
@onready var sigil_label: Label = $Margin/Content/IconStage/Sigil
@onready var rarity_gem: RarityGem = $Margin/Content/IconStage/Gem
@onready var name_label: Label = $Margin/Content/Name
@onready var category_label: Label = $Margin/Content/Category
@onready var level_label: Label = $Margin/Content/Level
@onready var description_label: Label = $Margin/Content/Description
@onready var effect_label: Label = $Margin/Content/Effect
@onready var relation_label: Label = $Margin/Content/Relation

var gene_data: GeneData
var selection_tween: Tween


func _ready() -> void:
	mouse_entered.connect(_set_selected.bind(true))
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_set_selected.bind(true))
	focus_exited.connect(_on_focus_exited)
	resized.connect(_update_pivot)
	call_deferred("_update_pivot")


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
	diamond_label.add_theme_color_override(
		"font_color",
		Color(rarity_color, 0.72)
	)
	rarity_gem.set_gem_color(rarity_color)
	_apply_rarity_styles(rarity_color)
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


func _apply_rarity_styles(rarity_color: Color) -> void:
	var normal := get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	var highlight := get_theme_stylebox("hover").duplicate() as StyleBoxFlat
	var pressed := get_theme_stylebox("pressed").duplicate() as StyleBoxFlat
	normal.border_color = Color(rarity_color, 0.42)
	highlight.border_color = rarity_color
	highlight.shadow_color = Color(rarity_color, 0.38)
	pressed.border_color = rarity_color.lightened(0.18)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", highlight)
	add_theme_stylebox_override("focus", highlight)
	add_theme_stylebox_override("pressed", pressed)


func _set_selected(is_selected: bool) -> void:
	if selection_tween != null:
		selection_tween.kill()
	z_index = 2 if is_selected else 0
	selection_tween = create_tween().set_parallel(true)
	selection_tween.tween_property(
		self,
		"scale",
		Vector2.ONE * (1.035 if is_selected else 1.0),
		0.14
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	selection_tween.tween_property(
		self,
		"modulate",
		Color(1.08, 1.05, 1.02, 1.0) if is_selected else Color.WHITE,
		0.14
	)


func _on_mouse_exited() -> void:
	if not has_focus():
		_set_selected(false)


func _on_focus_exited() -> void:
	if not is_hovered():
		_set_selected(false)


func _update_pivot() -> void:
	pivot_offset = size * 0.5
