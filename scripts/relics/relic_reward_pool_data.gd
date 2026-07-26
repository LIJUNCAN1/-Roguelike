class_name RelicRewardPoolData
extends Resource

@export_range(1, 3, 1) var choice_count: int = 2
@export var relics: Array[RelicData] = []


func get_available_relics(
	relic_manager: RelicManager
) -> Array[RelicData]:
	var available: Array[RelicData] = []
	if relic_manager == null:
		return available
	for relic in relics:
		if (
			relic != null
			and not relic.id.is_empty()
			and not relic_manager.has_relic(relic.id)
		):
			available.append(relic)
	return available
