class_name GeneCodexManager
extends Node

signal codex_changed
signal gene_discovered(gene: GeneData)

@export var gene_pool: GeneRewardPoolData
@export_node_path("Node") var gene_manager_path: NodePath
@export_node_path("Node") var room_manager_path: NodePath
@export var persistence_enabled: bool = true
@export var save_path: String = "user://gene_codex.cfg"

@onready var gene_manager: GeneManager = get_node(
	gene_manager_path
) as GeneManager
@onready var room_manager: RoomManager = get_node(
	room_manager_path
) as RoomManager

var seen_gene_ids: Dictionary = {}


func _ready() -> void:
	_load_codex()
	gene_manager.genes_changed.connect(_on_genes_changed)
	room_manager.room_changed.connect(_on_room_changed)
	_on_genes_changed()
	call_deferred("_discover_current_room_offers")


func discover_gene(gene: GeneData) -> bool:
	if gene == null or gene.id == &"" or seen_gene_ids.has(gene.id):
		return false
	seen_gene_ids[gene.id] = true
	_save_codex()
	gene_discovered.emit(gene)
	codex_changed.emit()
	return true


func is_gene_seen(gene_id: StringName) -> bool:
	return seen_gene_ids.has(gene_id)


func get_seen_count() -> int:
	return seen_gene_ids.size()


func get_all_genes() -> Array[GeneData]:
	var result: Array[GeneData] = []
	if gene_pool != null:
		result.assign(gene_pool.genes)
	return result


func _on_genes_changed() -> void:
	for gene in gene_manager.get_active_genes():
		discover_gene(gene)
	codex_changed.emit()


func _on_room_changed(_room_data: RoomData, _room_index: int) -> void:
	call_deferred("_discover_current_room_offers")


func _discover_current_room_offers() -> void:
	if room_manager.current_room is GeneRewardRoom:
		var reward_room := room_manager.current_room as GeneRewardRoom
		for gene in reward_room.get_offered_genes():
			discover_gene(gene)
	elif room_manager.current_room is GeneShopRoom:
		var shop_room := room_manager.current_room as GeneShopRoom
		for offer in shop_room.offers:
			if offer != null:
				discover_gene(offer.gene)


func _load_codex() -> void:
	if not persistence_enabled:
		return
	var config := ConfigFile.new()
	if config.load(save_path) != OK:
		return
	var stored_ids: PackedStringArray = config.get_value(
		"codex",
		"seen_gene_ids",
		PackedStringArray()
	)
	for stored_id in stored_ids:
		seen_gene_ids[StringName(stored_id)] = true


func _save_codex() -> void:
	if not persistence_enabled:
		return
	var stored_ids := PackedStringArray()
	for gene_id in seen_gene_ids:
		stored_ids.append(String(gene_id))
	stored_ids.sort()
	var config := ConfigFile.new()
	config.set_value("codex", "seen_gene_ids", stored_ids)
	var error := config.save(save_path)
	if error != OK:
		push_warning("Could not save gene codex: %s" % error_string(error))
