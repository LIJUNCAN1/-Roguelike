class_name GeneShopRoom
extends RoomController

signal offer_purchased(offer: ShopOfferData)

@export var offers: Array[ShopOfferData] = []

@onready var offer_areas: Array[Area2D] = [
	$OfferLeft,
	$OfferRight,
]
@onready var offer_labels: Array[Label] = [
	$OfferLeft/Label,
	$OfferRight/Label,
]
@onready var leave_area: Area2D = $LeaveArea
@onready var status_label: Label = $StatusLabel

var gene_manager: GeneManager
var progression: RunProgression


func _ready() -> void:
	completion_mode = CompletionMode.EXTERNAL
	for index in offer_areas.size():
		offer_areas[index].body_entered.connect(
			_on_offer_entered.bind(index)
		)
	leave_area.body_entered.connect(_on_leave_entered)
	_refresh_offers()


func configure_player(player: Node2D) -> void:
	gene_manager = player.get_node_or_null("GeneManager") as GeneManager
	progression = player.get_node_or_null(
		"RunProgression"
	) as RunProgression
	_refresh_offers()


func purchase_offer(index: int) -> bool:
	if (
		is_completed
		or gene_manager == null
		or progression == null
		or index < 0
		or index >= offers.size()
	):
		return false

	var offer := offers[index]
	if (
		offer == null
		or offer.gene == null
		or gene_manager.has_gene(offer.gene.id)
		or progression.coins < offer.coin_cost
	):
		status_label.text = "金币不足，或已经拥有该基因"
		status_label.modulate = Color(1, 0.42, 0.28, 1)
		return false

	if not progression.spend_coins(offer.coin_cost):
		return false
	if not gene_manager.add_gene(offer.gene):
		progression.add_coins(offer.coin_cost)
		return false

	status_label.text = "购入：%s" % offer.gene.display_name
	status_label.modulate = Color(0.45, 1, 0.68, 1)
	offer_purchased.emit(offer)
	_mark_completed()
	return true


func get_incomplete_hint() -> String:
	return "走进基因培养舱购买，或走进下方出口离开"


func _refresh_offers() -> void:
	for index in offer_labels.size():
		if index >= offers.size() or offers[index] == null:
			offer_areas[index].visible = false
			offer_areas[index].monitoring = false
			continue
		offer_areas[index].visible = true
		offer_areas[index].monitoring = true
		offer_labels[index].text = offers[index].get_display_text()
	if progression != null:
		status_label.text = "持有金币：%d" % progression.coins


func _on_offer_entered(body: Node2D, index: int) -> void:
	if body.get_node_or_null("GeneManager") == gene_manager:
		purchase_offer(index)


func _on_leave_entered(body: Node2D) -> void:
	if body.get_node_or_null("GeneManager") != gene_manager:
		return
	status_label.text = "保留金币，离开培养商店"
	_mark_completed()
