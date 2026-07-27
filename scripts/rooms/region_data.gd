class_name RegionData
extends Resource

@export_group("Identity")
@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var entry_objective: String = "继续深入区域"

@export_group("Palette")
@export var void_color: Color = Color(0.018, 0.025, 0.037, 1.0)
@export var floor_color: Color = Color(0.06, 0.09, 0.105, 1.0)
@export var patch_color: Color = Color(0.07, 0.115, 0.12, 1.0)
@export var wall_color: Color = Color(0.13, 0.25, 0.24, 1.0)
@export var accent_color: Color = Color(0.48, 1.0, 0.76, 1.0)

@export_group("Decoration")
@export var decoration_scene: PackedScene
@export var visual_data: RegionVisualData
