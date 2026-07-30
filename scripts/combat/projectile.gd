class_name Projectile
extends Area2D

signal impact_confirmed(damage_dealt: float)

@export var projectile_data: ProjectileData

@onready var body_visual: Polygon2D = $Body
@onready var tail_visual: Polygon2D = $Tail
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var travel_direction: Vector2 = Vector2.RIGHT
var attack_tags: Array[StringName] = []
var impact_effects: Array[ProjectileImpactEffect] = []
var source_actor: Node
var alive_time: float = 0.0
var hit_count: int = 0
var is_critical: bool = false


func setup(
	direction: Vector2,
	data_override: ProjectileData = null,
	tags: Array[StringName] = [],
	effects: Array[ProjectileImpactEffect] = [],
	attack_source: Node = null
) -> void:
	if not direction.is_zero_approx():
		travel_direction = direction.normalized()
	if data_override != null:
		projectile_data = data_override
	attack_tags.assign(tags)
	impact_effects.assign(effects)
	source_actor = attack_source
	rotation = travel_direction.angle()


func get_impact_direction() -> Vector2:
	return travel_direction


func _ready() -> void:
	if projectile_data == null:
		push_error("Projectile requires a ProjectileData resource.")
		queue_free()
		return

	body_visual.color = projectile_data.color
	if (
		projectile_data.critical_chance > 0.0
		and randf() <= projectile_data.critical_chance
	):
		projectile_data.damage *= (
			projectile_data.critical_damage_multiplier
		)
		is_critical = true
		if not attack_tags.has(&"critical_strike"):
			attack_tags.append(&"critical_strike")
	tail_visual.color = Color(
		projectile_data.color.r,
		projectile_data.color.g,
		projectile_data.color.b,
		0.35
	)

	var visual_scale := projectile_data.radius / 3.0
	body_visual.scale = Vector2.ONE * visual_scale
	tail_visual.scale = Vector2.ONE * visual_scale

	var runtime_shape := collision_shape.shape.duplicate() as CircleShape2D
	runtime_shape.radius = projectile_data.radius
	collision_shape.shape = runtime_shape
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if projectile_data == null:
		return

	_apply_homing(delta)
	global_position += travel_direction * projectile_data.speed * delta
	alive_time += delta

	if alive_time >= projectile_data.lifetime:
		queue_free()


func _apply_homing(delta: float) -> void:
	if projectile_data.homing_strength <= 0.0:
		return
	var nearest: Node2D
	var nearest_distance := projectile_data.homing_range
	for node in get_tree().get_nodes_in_group(&"room_enemies"):
		var candidate := node as Node2D
		if candidate == null:
			continue
		var distance := global_position.distance_to(
			candidate.global_position
		)
		if distance < nearest_distance:
			nearest = candidate
			nearest_distance = distance
	if nearest == null:
		return
	var target_direction := global_position.direction_to(
		nearest.global_position
	)
	travel_direction = travel_direction.rotated(
		clampf(
			travel_direction.angle_to(target_direction),
			-projectile_data.homing_strength * delta,
			projectile_data.homing_strength * delta
		)
	).normalized()
	rotation = travel_direction.angle()


func _on_area_entered(area: Area2D) -> void:
	if not area.has_method("receive_damage"):
		return

	var damage_dealt := float(
		area.call("receive_damage", projectile_data.damage, self)
	)
	if damage_dealt <= 0.0:
		return

	var hurtbox := area as HurtboxComponent
	var impact_context := ImpactContext.new(
		self,
		source_actor,
		hurtbox,
		global_position,
		damage_dealt
	)
	for effect in impact_effects:
		if effect != null:
			effect.apply(impact_context)

	impact_confirmed.emit(damage_dealt)
	hit_count += 1
	if hit_count >= projectile_data.max_hits:
		queue_free()
