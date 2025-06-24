class_name SFXMaster extends Node

enum SoundEnum {
	UI,
	Audio,
	Music
}

#region Variables

@export var sounds_ui: Array[SoundHolder]
@export var music_ui: Array[SoundHolder]
@onready var player_ui: AudioStreamPlayer = $PlayerUI
@onready var other_player: AudioStreamPlayer = $Other
@onready var music: AudioStreamPlayer = $Music
@onready var master_bus := AudioServer.get_bus_index("Master")
@onready var music_bus := AudioServer.get_bus_index("Music")
@onready var obstacle_bus := AudioServer.get_bus_index("Obstacles")
@onready var ui_bus := AudioServer.get_bus_index("UI")

var music_data: MusicHolder
#endregion

# Basic Godot functions
func _process(_delta: float) -> void:
	if music.playing:
		var time = music.get_playback_position() + AudioServer.get_time_since_last_mix()
		if time >= music_data.loop_points[music_data.which_loop].y && music_data.loop:
			music.seek(music_data.loop_points[music_data.which_loop].x)

# Play sound functions
func play_sound_ui_number(num : int):
	play(sounds_ui[num], SoundEnum.UI)

func play_sound_ui_string(text : String):
	for s in sounds_ui:
		if s.name == text:
			play(s, SoundEnum.UI)
			break

# Play music functions
func play_music(num: int):
	play(music_ui[num], SoundEnum.Music)

# Sound functions
func play(sound: SoundHolder, what: SoundEnum = SoundEnum.Audio):
	if sound == null:
		return
	match what:
		SoundEnum.UI:
			player_ui.stream = sound.stream
			player_ui.volume_db = sound.volume
			player_ui.play()
		SoundEnum.Music:
			sound = sound as MusicHolder
			if sound == music_data:
				return
			music.stream = sound.stream
			var offset = 0.0
			if sound.loop && !sound.start_from_start:
				offset = sound.loop_points[sound.which_loop].x
			music_data = sound
			music.play(offset)
		SoundEnum.Audio:
			other_player.stream = sound.stream
			other_player.volume_db = sound.volume
			other_player.play()

# Bus functions
func update_bus_volume(bus_name : String, val):
	match bus_name.capitalize():
		"Master":
			AudioServer.set_bus_volume_db(master_bus, linear_to_db(val))
		"Music":
			AudioServer.set_bus_volume_db(music_bus, linear_to_db(val))
		"Obstacle":
			AudioServer.set_bus_volume_db(obstacle_bus, linear_to_db(val))
		"Ui":
			AudioServer.set_bus_volume_db(ui_bus, linear_to_db(val))

func set_bus_muted(bus_name: String, val: bool):
	print(bus_name, ' ', val)
	match bus_name.capitalize():
		"Master":
			AudioServer.set_bus_mute(master_bus, val)
		"Music":
			AudioServer.set_bus_mute(music_bus, val)
		"Obstacle":
			AudioServer.set_bus_mute(obstacle_bus, val)
		"Ui":
			AudioServer.set_bus_mute(ui_bus, val)
