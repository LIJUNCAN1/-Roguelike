class_name StartArenaRoom
extends RoomController

signal opening_item_selected(item: RelicData)

@export var reward_pool: RelicRewardPoolData

@onready var choice_selector: RelicChoiceSelector = $RelicChoiceSelector
@onready var wave_spawner: WaveSpawner = $WaveSpawner
@onready var wave_status: Label = $WaveInterface/WaveStatus

var player: Node2D
var relic_manager: RelicManager
var offered_items: Array[RelicData] = []
var selected_item: RelicData
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	completion_mode = CompletionMode.EXTERNAL
	wave_status.visible = false
	choice_selector.visible = false
	choice_selector.relic_entered.connect(_on_item_entered)
	wave_spawner.wave_started.connect(_on_wave_started)
	wave_spawner.countdown_changed.connect(_on_countdown_changed)
	wave_spawner.all_waves_completed.connect(_on_all_waves_completed)


func configure_run(new_player: Node2D, run_seed: int) -> void:
	player = new_player
	relic_manager = player.get_node_or_null("RelicManager") as RelicManager
	_rng.seed = run_seed if run_seed != 0 else 1
	var world := player.get_parent()
	var effects := world.get_node_or_null("Effects") as Node2D
	var projectiles := world.get_node_or_null("Projectiles") as Node2D
	wave_spawner.configure(player, effects, projectiles, 1.0, run_seed)
	if player.has_method("set_input_enabled"):
		player.call("set_input_enabled", true)
	_offer_items()


func get_incomplete_hint() -> String:
	if selected_item == null:
		return "走上一个底座，选择一件开局物品"
	return "击败全部怪物波次"


func _offer_items() -> void:
	if relic_manager == null or reward_pool == null:
		push_error("StartArenaRoom requires an item pool and RelicManager.")
		return
	var available := reward_pool.get_available_relics(relic_manager)
	for index in range(available.size() - 1, 0, -1):
		var swap_index := _rng.randi_range(0, index)
		var item := available[index]
		available[index] = available[swap_index]
		available[swap_index] = item
	var offer_count := mini(2, available.size())
	offered_items.assign(available.slice(0, offer_count))
	if offered_items.is_empty():
		_start_waves()
		return
	choice_selector.visible = true
	choice_selector.configure(offered_items, player)


func _on_item_entered(choice_index: int) -> void:
	if (
		selected_item != null
		or choice_index < 0
		or choice_index >= offered_items.size()
	):
		return
	var item := offered_items[choice_index]
	if not relic_manager.add_relic(item):
		return
	selected_item = item
	choice_selector.visible = false
	opening_item_selected.emit(item)
	_start_waves()


func _start_waves() -> void:
	wave_status.visible = true
	wave_spawner.start()


func _on_wave_started(wave_number: int, wave_count: int) -> void:
	wave_status.text = "波次 %d / %d" % [wave_number, wave_count]


func _on_countdown_changed(seconds_remaining: float) -> void:
	if wave_spawner.current_wave_index >= wave_spawner.waves.size() - 1:
		return
	wave_status.text = "波次 %d / %d · 下一波 %.1f 秒" % [
		wave_spawner.current_wave_index + 1,
		wave_spawner.waves.size(),
		seconds_remaining,
	]


func _on_all_waves_completed() -> void:
	wave_status.text = "全部波次清除"
	_mark_completed()
