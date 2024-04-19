class_name MainMenu extends Control

# Variables
@onready var title = $MarginContainer/MenuPositions/Title
@onready var play_button = $MarginContainer/MenuPositions/PlayButton

# Signals
signal on_play_request
# Methods

func _ready():
	var title_name = ProjectSettings.get_setting("application/config/name")
	title.text =  "[center]%s[/center]" % title_name

func on_play_button_press():
	on_play_request.emit()
