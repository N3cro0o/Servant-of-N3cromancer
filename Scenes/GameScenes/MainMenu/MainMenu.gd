class_name MainMenu extends Control

# Variables
@onready var title = $MenuPanel/Title
@onready var play_button = $MenuPanel/MenuPositions/PlayButtonEndless
@onready var tutorial_panel = $MenuPanel/TutorialPanel

# Signals
signal on_play_request

# Methods
func _ready():
	var title_name = ProjectSettings.get_setting("application/config/name")
	title.text =  "[center]%s[/center]" % title_name
	GmM.curr_scene = self
	# Reset Score manager
	ScM.reset_score()


func on_play_button_press():
	GmM.change_scene(1)

func on_tutorial_text_button_press():
	tutorial_panel.visible = !tutorial_panel.visible

func on_shop_button_press():
	GmM.change_scene(2)

func on_quit_button_press():
	get_tree().quit()

func _notification(what):
	# Quit game
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
