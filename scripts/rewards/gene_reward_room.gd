class_name GeneRewardRoom
extends RoomController

signal reward_offered(choices: Array[GeneData])
signal reward_selected(gene: GeneData)

@export var reward_pool: GeneRewardPoolData

@onready var reward_interface: CanvasLayer = $RewardInterface
@onready var instruction_label: Label = (
	$RewardInterface/RewardPanel/Margin/Content/Instruction
)
@onready var choice_buttons: Array[GeneRewardCard] = [
	$RewardInterface/RewardPanel/Margin/Content/Cards/Choice1,
	$RewardInterface/RewardPanel/Margin/Content/Cards/Choice2,
	$RewardInterface/RewardPanel/Margin/Content/Cards/Choice3,
]

var gene_manager: GeneManager
var offered_genes: Array[GeneData] = []
var selected_gene: GeneData
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	completion_mode = CompletionMode.EXTERNAL
	_rng.randomize()
	reward_interface.visible = false
	for index in choice_buttons.size():
		choice_buttons[index].pressed.connect(
			_on_choice_pressed.bind(index)
		)


func _unhandled_input(event: InputEvent) -> void:
	if is_completed:
		return

	var choice_index := -1
	if event.is_action_pressed("reward_choice_1"):
		choice_index = 0
	elif event.is_action_pressed("reward_choice_2"):
		choice_index = 1
	elif event.is_action_pressed("reward_choice_3"):
		choice_index = 2

	if choice_index >= 0 and choose_gene(choice_index):
		get_viewport().set_input_as_handled()


func configure_player(player: Node2D) -> void:
	gene_manager = player.get_node_or_null("GeneManager") as GeneManager
	_offer_rewards()


func choose_gene(choice_index: int) -> bool:
	if (
		is_completed
		or gene_manager == null
		or choice_index < 0
		or choice_index >= offered_genes.size()
	):
		return false

	var gene := offered_genes[choice_index]
	if not gene_manager.add_gene(gene):
		return false

	selected_gene = gene
	for button in choice_buttons:
		button.disabled = true
	reward_interface.visible = false
	reward_selected.emit(gene)
	_mark_completed()
	return true


func get_offered_genes() -> Array[GeneData]:
	var choices: Array[GeneData] = []
	choices.assign(offered_genes)
	return choices


func get_incomplete_hint() -> String:
	return "选择一张基因卡（按 1 / 2 / 3）"


func _offer_rewards() -> void:
	if gene_manager == null or reward_pool == null:
		push_error("GeneRewardRoom requires a reward pool and GeneManager.")
		return

	var available := reward_pool.get_available_genes(gene_manager)
	_shuffle_genes(available)
	var offer_count: int = mini(reward_pool.choice_count, available.size())
	offered_genes.assign(available.slice(0, offer_count))

	if offered_genes.is_empty():
		reward_interface.visible = false
		_mark_completed()
		return

	for index in choice_buttons.size():
		var button := choice_buttons[index]
		if index >= offered_genes.size():
			button.visible = false
			continue
		var gene := offered_genes[index]
		button.configure(
			gene,
			index,
			_get_owned_series_genes(gene)
		)

	instruction_label.text = (
		"选择一段基因，让本次进化产生新的方向 · 按 1 / 2 / 3"
	)
	reward_interface.visible = true
	var focused_index := mini(1, offered_genes.size() - 1)
	choice_buttons[focused_index].grab_focus()
	reward_offered.emit(get_offered_genes())


func _shuffle_genes(genes: Array[GeneData]) -> void:
	for index in range(genes.size() - 1, 0, -1):
		var swap_index := _rng.randi_range(0, index)
		var gene := genes[index]
		genes[index] = genes[swap_index]
		genes[swap_index] = gene


func _on_choice_pressed(choice_index: int) -> void:
	choose_gene(choice_index)


func _get_owned_series_genes(gene: GeneData) -> Array[GeneData]:
	var related: Array[GeneData] = []
	if gene.series_id.is_empty():
		return related
	for owned_gene in gene_manager.get_active_genes():
		if owned_gene.series_id == gene.series_id:
			related.append(owned_gene)
	return related
