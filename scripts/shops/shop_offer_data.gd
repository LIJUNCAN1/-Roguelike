class_name ShopOfferData
extends Resource

@export var id: StringName
@export var gene: GeneData
@export_range(0, 10000, 1, "or_greater")
var coin_cost: int = 10


func get_display_text() -> String:
	if gene == null:
		return "无效商品"
	return "%s\n[%s · %s]\n%d 金币\n%s" % [
		gene.display_name,
		gene.get_rarity_name(),
		gene.get_category_name(),
		coin_cost,
		gene.description,
	]
