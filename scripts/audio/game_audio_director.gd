class_name GameAudioDirector
extends Node

@export var library: GameAudioLibrary
@export_node_path("Node2D") var player_path: NodePath
@export_node_path("Node") var room_manager_path: NodePath

@onready var player: Node2D = get_node(player_path) as Node2D
@onready var room_manager: RoomManager = get_node(
	room_manager_path
) as RoomManager

var music_player := AudioStreamPlayer.new()
var sfx_players: Array[AudioStreamPlayer] = []
var next_sfx_player: int = 0
var current_music_id: StringName
var rng := RandomNumberGenerator.new()
var audio_output_enabled: bool = true


func _ready() -> void:
	if library == null:
		push_error("GameAudioDirector requires a GameAudioLibrary.")
		return
	rng.randomize()
	audio_output_enabled = DisplayServer.get_name() != "headless"
	music_player.name = "MusicPlayer"
	music_player.bus = &"Music"
	add_child(music_player)
	for index in 8:
		var sfx_player := AudioStreamPlayer.new()
		sfx_player.name = "SfxPlayer%d" % index
		sfx_player.bus = &"SFX"
		add_child(sfx_player)
		sfx_players.append(sfx_player)
	player.attack_fired.connect(
		func(_projectile: Node2D) -> void: play_cue(library.attack)
	)
	player.dash_started.connect(
		func(_direction: Vector2) -> void: play_cue(library.dash)
	)
	var player_health := player.get_node(
		"HealthComponent"
	) as HealthComponent
	player_health.damaged.connect(_on_actor_damaged)
	player_health.died.connect(_on_actor_died)
	var evolution := player.get_node(
		"EvolutionSystem"
	) as EvolutionSystem
	evolution.evolution_changed.connect(_on_evolution_changed)
	room_manager.room_changed.connect(_on_room_changed)
	call_deferred("_bind_current_room_audio")


func _exit_tree() -> void:
	music_player.stop()
	music_player.stream = null
	for sfx_player in sfx_players:
		sfx_player.stop()
		sfx_player.stream = null
	sfx_players.clear()


func play_cue(cue: AudioCueData) -> void:
	if cue == null or sfx_players.is_empty():
		return
	var sfx_player := sfx_players[next_sfx_player]
	next_sfx_player = (next_sfx_player + 1) % sfx_players.size()
	sfx_player.stop()
	sfx_player.stream = (
		cue.stream if cue.stream != null else _synthesize_cue(cue)
	)
	sfx_player.volume_db = cue.volume_db
	sfx_player.pitch_scale = rng.randf_range(
		1.0 - cue.pitch_randomness,
		1.0 + cue.pitch_randomness
	)
	if audio_output_enabled:
		sfx_player.play()


func play_music(track: MusicTrackData) -> void:
	if track == null or track.id == current_music_id:
		return
	current_music_id = track.id
	music_player.stop()
	music_player.stream = (
		track.stream
		if track.stream != null
		else _synthesize_music(track)
	)
	music_player.volume_db = track.volume_db
	if audio_output_enabled:
		music_player.play()


func _on_room_changed(_data: RoomData, _index: int) -> void:
	call_deferred("_bind_current_room_audio")


func _bind_current_room_audio() -> void:
	var room_data := room_manager.get_current_room_data()
	if room_data == null:
		return
	if room_data.room_type == RoomData.RoomType.BOSS:
		play_music(library.boss_music)
	elif room_data.region != null:
		var track := library.region_music.get(
			room_data.region.id
		) as MusicTrackData
		play_music(track)

	for node in get_tree().get_nodes_in_group(&"room_enemies"):
		if (
			not node is EnemyController
			or not room_manager.current_room.is_ancestor_of(node)
		):
			continue
		var enemy := node as EnemyController
		if not enemy.health_component.damaged.is_connected(
			_on_actor_damaged
		):
			enemy.health_component.damaged.connect(_on_actor_damaged)
			enemy.health_component.died.connect(_on_actor_died)
		if enemy is BossController:
			var boss := enemy as BossController
			if not boss.phase_changed.is_connected(_on_boss_phase_changed):
				boss.phase_changed.connect(_on_boss_phase_changed)


func _on_actor_damaged(
	_amount: float,
	_current_health: float,
	_source: Node
) -> void:
	play_cue(library.hurt)


func _on_actor_died(_source: Node) -> void:
	play_cue(library.death)


func _on_evolution_changed(
	previous: EvolutionData,
	_current: EvolutionData
) -> void:
	if previous != null:
		play_cue(library.evolution)


func _on_boss_phase_changed(
	phase_index: int,
	_phase: BossPhaseData
) -> void:
	if phase_index > 0:
		play_cue(library.boss_phase)


func _synthesize_cue(cue: AudioCueData) -> AudioStreamWAV:
	var sample_rate := 22050
	var sample_count := maxi(
		int(cue.fallback_duration * sample_rate),
		1
	)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	var noise_rng := RandomNumberGenerator.new()
	noise_rng.seed = hash(cue.id)
	for index in sample_count:
		var time := float(index) / sample_rate
		var phase := time * cue.fallback_frequency * TAU
		var wave := 0.0
		match cue.fallback_waveform:
			AudioCueData.Waveform.SQUARE:
				wave = 1.0 if sin(phase) >= 0.0 else -1.0
			AudioCueData.Waveform.TRIANGLE:
				wave = asin(sin(phase)) * 2.0 / PI
			AudioCueData.Waveform.NOISE:
				wave = noise_rng.randf_range(-1.0, 1.0)
			_:
				wave = sin(phase)
		var normalized := float(index) / sample_count
		var envelope := minf(normalized / 0.08, 1.0) * (
			1.0 - smoothstep(0.55, 1.0, normalized)
		)
		bytes.encode_s16(
			index * 2,
			int(clampf(wave * envelope, -1.0, 1.0) * 18000.0)
		)
	return _create_wav(bytes, sample_rate, false)


func _synthesize_music(track: MusicTrackData) -> AudioStreamWAV:
	var sample_rate := 22050
	var beat_duration := 60.0 / track.fallback_tempo
	var notes := track.fallback_notes
	if notes.is_empty():
		notes = PackedFloat32Array([110.0])
	var total_duration := beat_duration * notes.size() * 2.0
	var sample_count := int(total_duration * sample_rate)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	for index in sample_count:
		var time := float(index) / sample_rate
		var note_index := int(time / beat_duration) % notes.size()
		var frequency := notes[note_index]
		var beat_phase := fmod(time, beat_duration) / beat_duration
		var pulse := (
			sin(time * frequency * TAU) * 0.65
			+ sin(time * frequency * 0.5 * TAU) * 0.25
		)
		var envelope := 0.55 + (1.0 - beat_phase) * 0.35
		bytes.encode_s16(
			index * 2,
			int(clampf(pulse * envelope, -1.0, 1.0) * 7500.0)
		)
	return _create_wav(bytes, sample_rate, true)


func _create_wav(
	bytes: PackedByteArray,
	sample_rate: int,
	should_loop: bool
) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	if should_loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = bytes.size() / 2
	return stream
