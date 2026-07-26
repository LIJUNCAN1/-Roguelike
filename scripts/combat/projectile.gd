class_name Projectile
extends Area2D

@export var projectile_data: ProjectileData

@onready var body_visual: Polygon2D = $Body
@onready var tail_visual: Polygon2D = $Tail
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var travel_direction: Vector2 = Vector2.RIGHT
var alive_time: float = 0.0
var hit_count: int = 0


func setup(direction: Vector2) -> void:
	if not direction.is_zero_approx():
		travel_direction = direction.normalized()
	rotation = travel_direction.angle()


func _ready() -> void:
	if projectile_data == null:
		push_error("Projectile requires a ProjectileData resource.")
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
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if projectile_data == null:
		return

	global_position += travel_direction * projectile_data.speed * delta
	alive_time += delta

	if alive_time >= projectile_data.lifetime:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if not area.has_method("receive_damage"):
		return

	var was_damaged := bool(
		area.call("receive_damage", projectile_data.damage, self)
	)
	if not was_damaged:
		return

	hit_count += 1
	if hit_count >= projectile_data.max_hits:
		queue_free()
