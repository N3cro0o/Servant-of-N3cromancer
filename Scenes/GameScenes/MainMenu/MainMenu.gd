class_name MainMenu extends Control

# Variables
@onready var title = $MenuPanel2/Title
@onready var play_button = $MenuPanel2/MenuPositions/PlayButtonEndless
@onready var tutorial_panel = $MenuPanel2/TutorialPanel

# Signals
#signal on_play_request

# Methods
func _ready():
	var title_name = ProjectSettings.get_setting("application/config/name")
	title.text =  str(title_name)
	GmM.curr_scene = self
	# Reset Score manager
	ScM.reset_score()

func _process(_delta):
	# Unlock endless
	play_button.disabled = !GmM.endless_unlock

func on_play_button_press():
	GmM.change_scene(1)
	Sfx.play_sound_ui_number(0)

func on_tutorial_text_button_press():
	tutorial_panel.visible = !tutorial_panel.visible
	Sfx.play_sound_ui_number(0)

func unlock_endless():
	pass

func on_shop_button_press():
	GmM.change_scene(2)
	Sfx.play_sound_ui_number(0)

func on_options_button_press():
	GmM.change_scene(3)
	Sfx.play_sound_ui_number(0)

func quit_game():
	await SvM.save_data()
	Sfx.play_sound_ui_number(0)
	get_tree().quit()

func on_quit_button_press():
	quit_game()

func _notification(what):
	# Quit game
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		quit_game()
