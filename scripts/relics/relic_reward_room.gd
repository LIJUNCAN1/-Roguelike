class_name RelicRewardRoom
extends RoomController

signal relic_selected(relic: RelicData)

@export var reward_pool: RelicRewardPoolData

@onready var choice_selector: RelicChoiceSelector = $RelicChoiceSelector
@onready var result_label: Label = $Result

var relic_manager: RelicManager
var offered_relics: Array[RelicData] = []
var selected_relic: RelicData
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	completion_mode = CompletionMode.EXTERNAL
	result_label.visible = false
	choice_selector.relic_entered.connect(_on_relic_entered)


func configure_run(player: Node2D, run_seed: int) -> void:
	relic_manager = player.get_node_or_null(
		"RelicManager"
	) as RelicManager
	_rng.seed = run_seed + 131071
	_offer_relics(player)


func get_incomplete_hint() -> String:
	return "走向一个祭坛选择秘宝"


func _offer_relics(player: Node2D) -> void:
	if relic_manager == null or reward_pool == null:
		push_error("RelicRewardRoom requires a pool and RelicManager.")
		return

	var available := reward_pool.get_available_relics(relic_manager)
	for index in range(available.size() - 1, 0, -1):
		var swap_index := _rng.randi_range(0, index)
		var relic := available[index]
		available[index] = available[swap_index]
		available[swap_index] = relic
	var offer_count: int = mini(
		reward_pool.choice_count,
		available.size()
	)
	offered_relics.assign(available.slice(0, offer_count))
	if offered_relics.is_empty():
		_mark_completed()
		return
	choice_selector.configure(offered_relics, player)


func _on_relic_entered(choice_index: int) -> void:
	if (
		is_completed
		or choice_index < 0
		or choice_index >= offered_relics.size()
	):
		return
	var relic := offered_relics[choice_index]
	if not relic_manager.add_relic(relic):
		return
	selected_relic = relic
	result_label.text = "已获得：%s · 按 N 前进" % relic.display_name
	result_label.visible = true
	relic_selected.emit(relic)
	_mark_completed()
