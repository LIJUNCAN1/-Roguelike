class_name WaveSpawner
extends Node2D

signal wave_started(wave_number: int, wave_count: int)
signal countdown_changed(seconds_remaining: float)
signal all_waves_completed

@export_range(0.25, 60.0, 0.25) var wave_interval: float = 6.0
@export var waves: Array[WaveData] = []
@export var spawn_positions: PackedVector2Array = PackedVector2Array()

var player: Node2D
var feedback_container: Node2D
var projectile_container: Node2D
var difficulty_multiplier: float = 1.0
var current_wave_index: int = -1
var living_enemy_count: int = 0
var countdown_remaining: float = 0.0
var is_running: bool = false
var _rng := RandomNumberGenerator.new()


func configure(
	new_player: Node2D,
	new_feedback_container: Node2D,
	new_projectile_container: Node2D,
	difficulty: float,
	run_seed: int
) -> void:
	player = new_player
	feedback_container = new_feedback_container
	projectile_container = new_projectile_container
	difficulty_multiplier = maxf(difficulty, 1.0)
	_rng.seed = run_seed if run_seed != 0 else 1


func start() -> void:
	if is_running:
		return
	is_running = true
	current_wave_index = -1
	living_enemy_count = 0
	_spawn_next_wave()


func _process(delta: float) -> void:
	if not is_running or current_wave_index >= waves.size() - 1:
		return
	countdown_remaining = maxf(countdown_remaining - delta, 0.0)
	countdown_changed.emit(countdown_remaining)
	if countdown_remaining <= 0.0:
		_spawn_next_wave()


func _spawn_next_wave() -> void:
	current_wave_index += 1
	if current_wave_index >= waves.size():
		_try_finish()
		return
	var wave := waves[current_wave_index]
	if wave == null:
		countdown_remaining = wave_interval
		return
	var enemy_scenes := wave.get_valid_enemies()
	for index in enemy_scenes.size():
		_spawn_enemy(enemy_scenes[index], index)
	wave_started.emit(current_wave_index + 1, waves.size())
	countdown_remaining = wave_interval
	countdown_changed.emit(countdown_remaining)
	_try_finish()


func _spawn_enemy(enemy_scene: PackedScene, enemy_index: int) -> void:
	var enemy := enemy_scene.instantiate() as EnemyController
	if enemy == null:
		push_error("WaveSpawner only accepts EnemyController scenes.")
		return
	add_child(enemy)
	var spawn_position := Vector2(960.0, 540.0)
	if not spawn_positions.is_empty():
		spawn_position = spawn_positions[
			enemy_index % spawn_positions.size()
		]
	enemy.position = spawn_position + Vector2(
		_rng.randf_range(-20.0, 20.0),
		_rng.randf_range(-20.0, 20.0)
	)
	enemy.add_to_group(&"room_enemies")
	enemy.set_target(player)
	enemy.set_feedback_container(feedback_container)
	enemy.set_projectile_container(projectile_container)
	enemy.apply_difficulty(difficulty_multiplier)
	var health := enemy.get_node_or_null("HealthComponent") as HealthComponent
	if health != null:
		living_enemy_count += 1
		health.died.connect(_on_enemy_died, CONNECT_ONE_SHOT)


func _on_enemy_died(_source: Node) -> void:
	living_enemy_count = maxi(living_enemy_count - 1, 0)
	_try_finish()


func _try_finish() -> void:
	if current_wave_index < waves.size() - 1 or living_enemy_count > 0:
		return
	is_running = false
	countdown_remaining = 0.0
	countdown_changed.emit(0.0)
	all_waves_completed.emit()
