class_name SFXMaster extends Node

@export var sounds_ui : Array[SoundHolder]
@onready var player_ui = $PlayerUI
@onready var master_bus := AudioServer.get_bus_index("Master")

func play_sound_ui_number(num : int):
	var sound : AudioStream = sounds_ui[num].stream
	play_ui_sound(sound)

func play_sound_ui_string(text : String):
	var sound : AudioStream
	for s in sounds_ui:
		if s.name == text:
			sound = s.stream
			break
	play_ui_sound(sound)

func play_ui_sound(sound : AudioStream):
	if sound == null:
		return
	player_ui.stream = sound
	player_ui.play()

func update_bus_volume(bus_name : String, val):
	match bus_name.capitalize():
		"Master":
			SvM.update_volume_master(val)
			AudioServer.set_bus_volume_db(master_bus, linear_to_db(val))
			print_rich("[hint=SFX]Volume master =[/hint] %f, %f" % [val, linear_to_db(val)])
