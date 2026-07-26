class_name ShopOfferData
extends Resource

@export var id: StringName
@export var gene: GeneData
@export_range(0, 10000, 1, "or_greater")
var essence_cost: int = 10


func get_display_text() -> String:
	if gene == null:
		return "无效商品"
	return "%s\n[%s · %s]\n%d 精华\n%s" % [
		gene.display_name,
		gene.get_rarity_name(),
		gene.get_category_name(),
		essence_cost,
		gene.description,
	]
