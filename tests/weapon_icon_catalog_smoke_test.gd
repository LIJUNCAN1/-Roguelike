extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var catalog := load(
		"res://data/weapons/icons/weapon_icon_catalog.tres"
	) as WeaponIconCatalogData
	if catalog == null or catalog.pages.size() != 6 or catalog.get_total_icon_count() != 180:
		push_error("Weapon icon catalog page count is invalid.")
		quit(1)
		return
	for page_index in catalog.pages.size():
		var icon := catalog.get_icon(page_index, 29)
		if icon == null or icon.region.size != Vector2(32, 32):
			push_error("Weapon icon region is invalid on page %d." % page_index)
			quit(1)
			return
	var weapon := load("res://data/weapons/twin_blade_weapon.tres") as WeaponData
	if weapon == null or weapon.get_icon() == null:
		push_error("Starting melee weapon icon is missing.")
		quit(1)
		return
	print("Weapon icon catalog smoke test passed.")
	quit()
