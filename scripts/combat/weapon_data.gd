class_name WeaponData
extends Resource

@export_group("Presentation")
@export var attack_cue: AudioCueData
@export var impact_cue: AudioCueData

@export_group("Projectile")
@export var projectile_scene: PackedScene
@export var projectile_data: ProjectileData
@export_range(0.01, 10.0, 0.01, "or_greater")
var fire_cooldown: float = 0.22
@export_range(0.0, 100.0, 1.0, "or_greater")
var muzzle_distance: float = 12.0
