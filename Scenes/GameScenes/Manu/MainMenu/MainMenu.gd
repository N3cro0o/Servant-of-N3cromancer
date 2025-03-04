class_name MainMenu extends Control

#region Variables

@onready var title = $MenuPanel2/Title
@onready var play_button = $MenuPanel2/MenuPositions/PlayButtonEndless
@onready var tutorial_panel = $MenuPanel2/TutorialPanel

#endregion

# Basic Godot functions
func _ready():
	var title_name = ProjectSettings.get_setting("application/config/name")
	title.text =  str(title_name)
	GmM.curr_scene = self
	# Reset Score manager
	ScM.reset_score()
	# Save only if data is updated
	if !SvM.check_data(SvM.SAVE_PATH):
		SvM.save_data()
	if !GmM.web_development:
		$"GPUParticles2D-1".amount_ratio = SvM.return_particle_amount()
	else:
		$"GPUParticles2D-1".clip_children = CLIP_CHILDREN_DISABLED
		$"GPUParticles2D-1".emitting = false

func _process(_delta):
	# Unlock endless
	play_button.disabled = !GmM.endless_unlock
	# Funny debug thing
	#$MenuPanel2/MenuPositions/QuitButton.text = str(get_window().size)
	#$MenuPanel2/MenuPositions/OptionsButton.text = str(get_viewport().size)

func _notification(what):
	# Quit game
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		quit_game()

# Buttons functions
func on_play_button_press():
	GmM.change_scene(1)
	Sfx.play_sound_ui_number(0)

func on_tutorial_text_button_press():
	#tutorial_panel.visible = !tutorial_panel.visible
	GmM.change_scene(4)
	Sfx.play_sound_ui_number(0)

func unlock_endless():
	pass

func on_shop_button_press():
	GmM.change_scene(2)
	Sfx.play_sound_ui_number(0)

func on_options_button_press():
	GmM.change_scene(3)
	Sfx.play_sound_ui_number(0)

func on_quit_button_press():
	quit_game()

# App functions
func quit_game():
	await SvM.save_data()
	Sfx.play_sound_ui_number(0)
	get_tree().quit()
