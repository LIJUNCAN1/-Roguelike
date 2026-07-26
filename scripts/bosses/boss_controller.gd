class_name BossController
extends EnemyController

signal phase_changed(phase_index: int, phase: BossPhaseData)
signal attack_telegraphed(attack: BossAttackData, world_position: Vector2)
signal attack_resolved(hit_player: bool)

@export var attack_indicator_scene: PackedScene

@onready var body_visual: Polygon2D = $Visuals/Body
@onready var core_visual: Polygon2D = $Visuals/Core
@onready var phase_label: Label = $PhaseLabel
@onready var health_bar: ProgressBar = $BossHealthBar

var boss_data: BossData
var current_phase_index: int = 0
var current_phase: BossPhaseData
var attack_cooldown_remaining: float = 0.8
var telegraph_remaining: float = 0.0
var pending_attack_position: Vector2
var active_indicator: BossAttackIndicator


func _ready() -> void:
	super._ready()
	boss_data = enemy_data as BossData
	if (
		boss_data == null
		or boss_data.phases.is_empty()
		or boss_data.phases[0] == null
	):
		push_error("Boss requires BossData with at least one phase.")
		set_physics_process(false)
		return

	health_component.health_changed.connect(_on_health_changed)
	health_bar.max_value = health_component.max_health
	health_bar.value = health_component.current_health
	_apply_phase(0)


func _physics_process(delta: float) -> void:
	if (
		current_phase == null
		or health_component.is_dead
		or target == null
		or not is_instance_valid(target)
	):
		movement_component.move(self, Vector2.ZERO)
		return

	if telegraph_remaining > 0.0:
		movement_component.move(self, Vector2.ZERO)
		telegraph_remaining -= delta
		if telegraph_remaining <= 0.0:
			_resolve_attack()
		return

	attack_cooldown_remaining = maxf(
		attack_cooldown_remaining - delta,
		0.0
	)
	var target_offset := target.global_position - global_position
	var target_distance := target_offset.length()
	if (
		current_phase.attack != null
		and attack_cooldown_remaining <= 0.0
		and target_distance <= current_phase.attack.trigger_range
	):
		_begin_attack()
		return

	if target_distance <= current_phase.preferred_distance:
		movement_component.move(self, Vector2.ZERO)
		return
	facing_direction = target_offset.normalized()
	_update_facing_visual()
	movement_component.move(self, facing_direction)


func _begin_attack() -> void:
	var attack := current_phase.attack
	if attack == null or attack_indicator_scene == null:
		return

	pending_attack_position = target.global_position
	telegraph_remaining = attack.telegraph_duration
	active_indicator = (
		attack_indicator_scene.instantiate() as BossAttackIndicator
	)
	get_parent().add_child(active_indicator)
	active_indicator.global_position = pending_attack_position
	active_indicator.configure(
		attack.radius,
		attack.warning_color,
		attack.telegraph_duration
	)
	phase_label.text = "%s · %s" % [
		current_phase.display_name,
		attack.display_name,
	]
	attack_telegraphed.emit(attack, pending_attack_position)


func _resolve_attack() -> void:
	var attack := current_phase.attack
	if attack == null:
		return

	var hit_player := (
		target != null
		and is_instance_valid(target)
		and target.global_position.distance_to(pending_attack_position)
			<= attack.radius
	)
	if hit_player:
		var player_health := target.get_node_or_null(
			"HealthComponent"
		) as HealthComponent
		if player_health != null:
			player_health.take_damage(attack.damage, self)

	if active_indicator != null and is_instance_valid(active_indicator):
		active_indicator.impact()
	active_indicator = null
	attack_cooldown_remaining = attack.cooldown
	phase_label.text = current_phase.display_name
	attack_resolved.emit(hit_player)


func _on_health_changed(
	current_health: float,
	max_health: float
) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health
	if boss_data == null or max_health <= 0.0:
		return

	var health_ratio := current_health / max_health
	var next_phase_index := 0
	for index in boss_data.phases.size():
		var phase := boss_data.phases[index]
		if (
			phase != null
			and health_ratio <= phase.enter_health_ratio
		):
			next_phase_index = index
	if next_phase_index != current_phase_index:
		_apply_phase(next_phase_index)


func _apply_phase(phase_index: int) -> void:
	if (
		boss_data == null
		or phase_index < 0
		or phase_index >= boss_data.phases.size()
		or boss_data.phases[phase_index] == null
	):
		return

	current_phase_index = phase_index
	current_phase = boss_data.phases[phase_index]
	movement_component.configure(current_phase.move_speed)
	body_visual.color = current_phase.body_color
	core_visual.color = current_phase.core_color
	phase_label.text = current_phase.display_name
	if current_phase.attack != null:
		attack_cooldown_remaining = minf(
			attack_cooldown_remaining,
			current_phase.attack.cooldown
		)
	phase_changed.emit(current_phase_index, current_phase)


func _on_died(source: Node) -> void:
	if active_indicator != null and is_instance_valid(active_indicator):
		active_indicator.queue_free()
	active_indicator = null
	super._on_died(source)
