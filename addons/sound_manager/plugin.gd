@tool
extends EditorPlugin

var _registered_autoload := false

func _enter_tree() -> void:
	set_up_default_buses()
	if not ProjectSettings.has_setting("autoload/SoundManager"):
		add_autoload_singleton("SoundManager", "res://addons/sound_manager/sound_manager.gd")
		_registered_autoload = true


func _exit_tree() -> void:
	if _registered_autoload and ProjectSettings.has_setting("autoload/SoundManager"):
		remove_autoload_singleton("SoundManager")


func set_up_default_buses() -> void:
	print("Checking default buses for Sound Manager")
	
	# Project adapter: the game already exposes Music and SFX in both
	# settings menus, so the plugin must not create duplicate buses.
	var default_buses : PackedStringArray = ["Master", "Music", "SFX"]
	print("Default Sound Manager buses : ",default_buses)
	
	for bus : String in default_buses:
		if AudioServer.get_bus_index(bus) == -1:
			print(bus, " is missing")
			var bus_position : int = AudioServer.bus_count
			AudioServer.add_bus(bus_position)
			AudioServer.set_bus_name(bus_position, bus)
			AudioServer.set_bus_send(bus_position, "Master")
			print("Added bus ", bus, " at position ", bus_position)
	
	# add and remove an extra bus so last added bus is updated properly (see issue 119109)
	AudioServer.add_bus()
	AudioServer.remove_bus(AudioServer.bus_count-1)
	
	print("Sound Manager default buses set up")
