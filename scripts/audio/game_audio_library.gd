class_name GameAudioLibrary
extends Resource

@export_group("Combat Cues")
@export var attack: AudioCueData
@export var attack_impact: AudioCueData
@export var dash: AudioCueData
@export var hurt: AudioCueData
@export var death: AudioCueData
@export var evolution: AudioCueData
@export var boss_phase: AudioCueData

@export_group("Music")
@export var region_music: Dictionary = {}
@export var boss_music: MusicTrackData
