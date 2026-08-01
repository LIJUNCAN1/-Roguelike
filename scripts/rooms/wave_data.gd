class_name WaveData
extends Resource

@export var enemies: Array[PackedScene] = []


func get_valid_enemies() -> Array[PackedScene]:
	var valid: Array[PackedScene] = []
	for enemy_scene in enemies:
		if enemy_scene != null:
			valid.append(enemy_scene)
	return valid
