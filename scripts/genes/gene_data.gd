class_name GeneData
extends Resource

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY,
}

enum Category {
	COMBUSTION,
	PROLIFERATION,
	SURVIVAL,
	ADAPTATION,
	ABYSS,
	MECHANICAL,
	ELEMENTAL,
	SUMMONING,
}

@export_group("Identity")
@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var rarity: Rarity = Rarity.COMMON
@export var category: Category = Category.ADAPTATION
@export var tags: Array[StringName] = []

@export_group("Codex")
@export var series_id: StringName
@export var series_name: String
@export var evolution_links: Array[StringName] = []

@export_group("Effects")
@export var effects: Array[GeneEffect] = []
@export var passive_effects: Array[GenePassiveEffect] = []


func get_rarity_name() -> String:
	match rarity:
		Rarity.UNCOMMON:
			return "稀有"
		Rarity.RARE:
			return "史诗"
		Rarity.EPIC:
			return "传说"
		Rarity.LEGENDARY:
			return "神话"
	return "普通"


func get_rarity_color_hex() -> String:
	match rarity:
		Rarity.UNCOMMON:
			return "#5aa8ff"
		Rarity.RARE:
			return "#bd68ff"
		Rarity.EPIC:
			return "#ff9b35"
		Rarity.LEGENDARY:
			return "#ff3f45"
	return "#eef4f2"


func get_category_name() -> String:
	match category:
		Category.COMBUSTION:
			return "燃烧系"
		Category.PROLIFERATION:
			return "增殖系"
		Category.SURVIVAL:
			return "生存系"
		Category.ABYSS:
			return "深渊系"
		Category.MECHANICAL:
			return "机械系"
		Category.ELEMENTAL:
			return "元素系"
		Category.SUMMONING:
			return "召唤系"
	return "适应系"


func has_tag(tag: StringName) -> bool:
	return not tag.is_empty() and tags.has(tag)


func links_to_evolution(evolution_id: StringName) -> bool:
	return evolution_links.has(evolution_id)


func get_tags_text() -> String:
	var formatted := PackedStringArray()
	for tag in tags:
		formatted.append("#%s" % String(tag))
	return " ".join(formatted)


func get_evolution_links_text() -> String:
	var formatted := PackedStringArray()
	for evolution_id in evolution_links:
		formatted.append(String(evolution_id))
	return "、".join(formatted)
