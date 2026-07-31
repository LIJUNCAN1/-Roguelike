extends SceneTree

const SCENES := [
	"res://scenes/enemies/test_chaser.tscn",
	"res://scenes/enemies/rat.tscn",
	"res://scenes/enemies/slime.tscn",
	"res://scenes/enemies/reward_mimic.tscn",
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for scene_path in SCENES:
		var packed := load(scene_path) as PackedScene
		if packed == null:
			_fail("无法加载：%s" % scene_path)
			return
		var enemy := packed.instantiate() as EnemyController
		if enemy == null:
			_fail("不是 EnemyController：%s" % scene_path)
			return
		root.add_child(enemy)
		await process_frame
		var presenter := enemy.get_node_or_null("EnemyAnimationPresenter") as EnemyAnimationPresenter
		if presenter == null or presenter.animation_set == null:
			_fail("缺少动画 Presenter：%s" % scene_path)
			return
		var sprite := presenter.get_node_or_null("AnimatedEnemySprite") as AnimatedSprite2D
		if sprite == null or not sprite.sprite_frames.has_animation(&"death"):
			_fail("动画帧未构建：%s" % scene_path)
			return
		enemy.queue_free()
		await process_frame

	var reward_room := load("res://scenes/rooms/reward_room.tscn").instantiate() as GeneRewardRoom
	root.add_child(reward_room)
	await process_frame
	if reward_room.get_node_or_null("RewardMimic") == null or reward_room.reward_interface.visible:
		_fail("奖励房拟态怪流程初始状态错误")
		return
	var player := load("res://scenes/player/player.tscn").instantiate() as Node2D
	root.add_child(player)
	reward_room.configure_player(player)
	var mimic := reward_room.get_node("RewardMimic") as EnemyController
	(mimic.get_node("HealthComponent") as HealthComponent).take_damage(10000.0, player)
	await create_timer(0.05).timeout
	if not reward_room.reward_interface.visible:
		_fail("拟态怪死亡后没有显示基因奖励")
		return
	reward_room.queue_free()
	player.queue_free()
	print("ENEMY_ANIMATION_SMOKE_TEST_OK")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
