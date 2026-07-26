class_name MenuGeneCodex
extends PanelContainer

@export var gene_pool: GeneRewardPoolData
@export_node_path("RichTextLabel") var text_path: NodePath

@onready var text_label: RichTextLabel = get_node(
	text_path
) as RichTextLabel


func _ready() -> void:
	var lines := PackedStringArray()
	if gene_pool != null:
		for gene in gene_pool.genes:
			if gene == null:
				continue
			lines.append(
				"[color=%s]%s · %s · %s[/color]\n%s" % [
					gene.get_rarity_color_hex(),
					gene.display_name,
					gene.get_rarity_name(),
					gene.get_category_name(),
					gene.description,
				]
			)
	text_label.text = "\n\n".join(lines)
