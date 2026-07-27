extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := (
		load("res://scenes/main/main.tscn") as PackedScene
	).instantiate()
	root.add_child(main)
	await physics_frame
	await process_frame

	var player := main.get_node("World/Player") as CharacterBody2D
	var player_presenter := player.get_node(
		"PixelActorPresenter"
	) as PixelActorPresenter
	if (
		not player_presenter.sprite.visible
		or player_presenter.visual_data == null
		or player_presenter.sprite.texture == null
		or player.get_node("Visuals").visible
	):
		push_error("Player pixel visual replacement was not active.")
		quit(1)
		return

	var audio := main.get_node(
		"GameAudioDirector"
	) as GameAudioDirector
	if (
		audio.library == null
		or audio.current_music_id != &"organic_region"
		or not audio.music_player.stream is AudioStreamWAV
		or audio.music_player.bus != &"Music"
	):
		push_error("Region music fallback was not active.")
		quit(1)
		return
	for sfx_player in audio.sfx_players:
		if sfx_player.bus != &"SFX":
			push_error("Sound effect player was not routed to SFX.")
			quit(1)
			return

	var room_manager := main.get_node("RoomManager") as RoomManager
	room_manager.enter_room(1)
	await process_frame
	var enemy := room_manager.current_room.get_node(
		"TestChaser"
	) as EnemyController
	var enemy_presenter := enemy.get_node(
		"PixelActorPresenter"
	) as PixelActorPresenter
	if (
		not enemy_presenter.sprite.visible
		or enemy_presenter.visual_data != enemy.enemy_data.visual_data
		or enemy.get_node("Visuals").visible
	):
		push_error("Enemy pixel visual replacement was not active.")
		quit(1)
		return

	player.aim_at(enemy.global_position)
	var projectile: Node2D = player.fire() as Node2D
	if (
		projectile == null
		or player_presenter.current_state != &"attack"
		or not _any_sfx_loaded(audio)
	):
		push_error("Attack animation or attack audio did not trigger.")
		quit(1)
		return

	var region := load(
		"res://data/regions/abyss_lab.tres"
	) as RegionData
	if (
		region.visual_data == null
		or region.visual_data.source_atlas == null
		or region.visual_data.tile_set != null
	):
		push_error("Region art replacement interface is invalid.")
		quit(1)
		return
	if not room_manager.current_room.has_node(
		"RoomShell/RegionDecorations/GeneratedTileBackdrop"
	):
		push_error("Generated region tiles were not rendered in the room.")
		quit(1)
		return

	var custom_stream := AudioStreamWAV.new()
	var cue := AudioCueData.new()
	cue.stream = custom_stream
	audio.play_cue(cue)
	var used_custom_stream := false
	for sfx_player in audio.sfx_players:
		if sfx_player.stream == custom_stream:
			used_custom_stream = true
			break
	if not used_custom_stream:
		push_error("External audio replacement stream was ignored.")
		quit(1)
		return

	print("Art and audio smoke test passed.")
	quit()


func _any_sfx_loaded(audio: GameAudioDirector) -> bool:
	for sfx_player in audio.sfx_players:
		if sfx_player.stream != null:
			return true
	return false
