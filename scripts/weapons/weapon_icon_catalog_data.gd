class_name WeaponIconCatalogData
extends Resource

@export var pages: Array[WeaponAtlasPageData] = []


func get_icon(page_index: int, icon_index: int) -> AtlasTexture:
	if page_index < 0 or page_index >= pages.size():
		return null
	var page := pages[page_index]
	return null if page == null else page.get_icon(icon_index)


func get_total_icon_count() -> int:
	var total := 0
	for page in pages:
		if page != null:
			total += page.get_icon_count()
	return total

