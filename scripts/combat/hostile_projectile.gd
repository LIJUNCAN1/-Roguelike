class_name HostileProjectile
extends Area2D

@export var projectile_data: ProjectileData

@onready var body_visual: Polygon2D = $Body
@onready var tail_visual: Polygon2D = $Tail
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var travel_direction: Vector2 = Vector2.LEFT
var source_actor: Node
var alive_time: float = 0.0


func setup(
	direction: Vector2,
	data_override: ProjectileData,
	attack_source: Node = null
) -> void:
	if not direction.is_zero_approx():
		travel_direction = direction.normalized()
	if data_override != null:
		projectile_data = data_override.duplicate(true) as ProjectileData
	source_actor = attack_source
	rotation = travel_direction.angle()


func _ready() -> void:
	if projectile_data == null:
		push_error("Hostile projectile requires ProjectileData.")
		queue_free()
		return

	body_visual.color = projectile_data.color
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
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if projectile_data == null:
		return
	global_position += travel_direction * projectile_data.speed * delta
	alive_time += delta
	if alive_time >= projectile_data.lifetime:
		queue_free()


func get_impact_direction() -> Vector2:
	return travel_direction


func _on_body_entered(body: Node2D) -> void:
	var health := body.get_node_or_null(
		"HealthComponent"
	) as HealthComponent
	if health != null:
		health.take_damage(projectile_data.damage, self)
	queue_free()
