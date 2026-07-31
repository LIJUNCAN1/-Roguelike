class_name RewardMimicController
extends EnemyController

@export_range(24.0, 300.0, 1.0) var activation_radius: float = 92.0

var awakened: bool = false


func _physics_process(delta: float) -> void:
	if is_dying:
		return
	if not awakened:
		movement_component.move(self, Vector2.ZERO)
		if target != null and global_position.distance_to(target.global_position) <= activation_radius:
			awakened = true
			var presenter := get_node_or_null("EnemyAnimationPresenter") as EnemyAnimationPresenter
			if presenter != null:
				presenter.play_awaken()
		return
	super._physics_process(delta)

