extends SceneTree

const SFXRConfig = preload("res://addons/gdfxr/SFXRConfig.gd")
const SFXRGenerator = preload("res://addons/gdfxr/SFXRGenerator.gd")
const OUTPUT_DIRECTORY := "res://assets/audio/generated"


func _init() -> void:
	call_deferred("_generate_all")


func _generate_all() -> void:
	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	)
	var presets := {
		"menu_hover": _menu_hover(),
		"menu_confirm": _menu_confirm(),
		"menu_transition": _menu_transition(),
		"attack": _attack(),
		"dash": _dash(),
		"hurt": _hurt(),
		"death": _death(),
		"evolution": _evolution(),
		"boss_phase": _boss_phase(),
	}
	var generator := SFXRGenerator.new()
	for cue_name: String in presets:
		seed(hash(cue_name))
		var stream := generator.generate_audio_stream(
			presets[cue_name],
			SFXRGenerator.WavBits.WAV_BITS_16,
			SFXRGenerator.WavFreq.WAV_FREQ_44100
		)
		var path := "%s/%s.res" % [OUTPUT_DIRECTORY, cue_name]
		var error := ResourceSaver.save(
			stream,
			path,
			ResourceSaver.FLAG_COMPRESS
		)
		if error != OK:
			push_error("Failed to save generated SFX: %s" % path)
			quit(1)
			return
	print("Generated %d gdfxr sound effects." % presets.size())
	quit()


func _new_config() -> RefCounted:
	var config := SFXRConfig.new()
	config.sound_vol = 0.62
	config.p_lpf_freq = 1.0
	return config


func _menu_hover() -> RefCounted:
	var config := _new_config()
	config.wave_type = SFXRConfig.WaveType.SINE_WAVE
	config.p_base_freq = 0.58
	config.p_env_attack = 0.0
	config.p_env_sustain = 0.035
	config.p_env_decay = 0.07
	config.p_arp_speed = 0.55
	config.p_arp_mod = 0.12
	config.p_hpf_freq = 0.08
	return config


func _menu_confirm() -> RefCounted:
	var config := _new_config()
	config.wave_type = SFXRConfig.WaveType.SQUARE_WAVE
	config.p_base_freq = 0.48
	config.p_env_attack = 0.0
	config.p_env_sustain = 0.08
	config.p_env_decay = 0.14
	config.p_env_punch = 0.3
	config.p_arp_speed = 0.62
	config.p_arp_mod = 0.25
	config.p_duty = 0.42
	config.p_lpf_freq = 0.72
	return config


func _menu_transition() -> RefCounted:
	var config := _new_config()
	config.wave_type = SFXRConfig.WaveType.SAWTOOTH
	config.p_base_freq = 0.22
	config.p_freq_ramp = 0.24
	config.p_env_attack = 0.02
	config.p_env_sustain = 0.22
	config.p_env_decay = 0.32
	config.p_env_punch = 0.18
	config.p_lpf_freq = 0.68
	config.p_lpf_ramp = 0.12
	config.p_pha_offset = 0.12
	return config


func _attack() -> RefCounted:
	var config := _new_config()
	config.wave_type = SFXRConfig.WaveType.SAWTOOTH
	config.p_base_freq = 0.64
	config.p_freq_limit = 0.18
	config.p_freq_ramp = -0.46
	config.p_env_attack = 0.0
	config.p_env_sustain = 0.045
	config.p_env_decay = 0.1
	config.p_hpf_freq = 0.12
	config.p_pha_offset = -0.14
	return config


func _dash() -> RefCounted:
	var config := _new_config()
	config.wave_type = SFXRConfig.WaveType.NOISE
	config.p_base_freq = 0.28
	config.p_freq_ramp = -0.18
	config.p_env_attack = 0.0
	config.p_env_sustain = 0.12
	config.p_env_decay = 0.18
	config.p_lpf_freq = 0.48
	config.p_lpf_ramp = -0.2
	config.p_hpf_freq = 0.18
	return config


func _hurt() -> RefCounted:
	var config := _new_config()
	config.wave_type = SFXRConfig.WaveType.NOISE
	config.p_base_freq = 0.25
	config.p_freq_ramp = -0.3
	config.p_env_attack = 0.0
	config.p_env_sustain = 0.06
	config.p_env_decay = 0.16
	config.p_env_punch = 0.38
	config.p_lpf_freq = 0.38
	return config


func _death() -> RefCounted:
	var config := _new_config()
	config.wave_type = SFXRConfig.WaveType.NOISE
	config.p_base_freq = 0.2
	config.p_freq_ramp = -0.24
	config.p_env_attack = 0.0
	config.p_env_sustain = 0.26
	config.p_env_decay = 0.48
	config.p_env_punch = 0.32
	config.p_lpf_freq = 0.28
	config.p_pha_offset = -0.24
	return config


func _evolution() -> RefCounted:
	var config := _new_config()
	config.wave_type = SFXRConfig.WaveType.SINE_WAVE
	config.p_base_freq = 0.24
	config.p_freq_ramp = 0.28
	config.p_env_attack = 0.03
	config.p_env_sustain = 0.32
	config.p_env_decay = 0.45
	config.p_env_punch = 0.26
	config.p_repeat_speed = 0.58
	config.p_arp_speed = 0.72
	config.p_arp_mod = 0.34
	return config


func _boss_phase() -> RefCounted:
	var config := _new_config()
	config.wave_type = SFXRConfig.WaveType.SQUARE_WAVE
	config.p_base_freq = 0.16
	config.p_freq_ramp = -0.08
	config.p_env_attack = 0.02
	config.p_env_sustain = 0.42
	config.p_env_decay = 0.58
	config.p_env_punch = 0.55
	config.p_duty = 0.62
	config.p_vib_strength = 0.24
	config.p_vib_speed = 0.28
	config.p_lpf_freq = 0.42
	config.p_pha_offset = 0.28
	return config
