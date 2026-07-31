class_name WeaponData
extends Resource

@export_group("Presentation")
@export var display_name: String = "武器"
@export var icon: Texture2D
@export var icon_catalog: WeaponIconCatalogData
@export_range(0, 128, 1) var icon_page: int = 0
@export_range(0, 1024, 1) var icon_index: int = 0
@export var attack_cue: AudioCueData
@export var impact_cue: AudioCueData

@export_group("Projectile")
@export var projectile_scene: PackedScene
@export var projectile_data: ProjectileData
@export_range(0.01, 10.0, 0.01, "or_greater")
var fire_cooldown: float = 0.22
@export_range(0.0, 100.0, 1.0, "or_greater")
var muzzle_distance: float = 12.0


func get_icon() -> Texture2D:
	if icon_catalog != null:
		var catalog_icon := icon_catalog.get_icon(icon_page, icon_index)
		if catalog_icon != null:
			return catalog_icon
	return icon
