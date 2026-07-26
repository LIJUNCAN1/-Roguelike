class_name MetaUpgradeCatalog
extends Resource

@export var upgrades: Array[MetaUpgradeData] = []


func get_upgrade(upgrade_id: StringName) -> MetaUpgradeData:
	for upgrade in upgrades:
		if upgrade != null and upgrade.id == upgrade_id:
			return upgrade
	return null
