class_name WeaponData
extends Resource

@export var projectile_scene: PackedScene
@export_range(0.01, 10.0, 0.01, "or_greater")
var fire_cooldown: float = 0.22
@export_range(0.0, 100.0, 1.0, "or_greater")
var muzzle_distance: float = 12.0
