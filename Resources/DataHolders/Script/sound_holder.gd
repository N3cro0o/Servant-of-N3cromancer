class_name SoundHolder extends Resource

@export var name : String
@export var stream : AudioStream
@export var volume : float
@export var autoplay : bool
@export_enum("Master", "Music", "Obstacles", "UI") var bus : String = "Master"
