class_name GameOverScreen extends Control

const descritpion : String = "Score: %d\nCoins: %d\nDistance: %d meters"
const descritpion_score : String = "New Hi Score! %d\nCoins: %d\nDistance: %d m"

#region Variables
@export_range(0, 25) var time = 10.0

@onready var name_label = $Margin/Box/Upper/YouDiedBruhLabel
@onready var desc_label = $Margin/Box/Middle/DescriptionLabel
@onready var reset_label = $Margin/Box/Bottom/VBoxContainer/ResetTimerLabel

var timer = 0

signal on_reset_request
signal on_quit_request
#endregion

func update_desc():
	var arr = [ScM.score, ScM.coins, snappedf(ScM.distance, 1)]
	if ScM.score > ScM.highscore:
		desc_label.text = descritpion_score % arr
	else:
		desc_label.text = descritpion % arr
	visible = true
	SvM.save_data()

func _process(delta):
	if visible:
		timer += delta
		if(timer >= time):
			on_reset_request.emit()
		reset_label.text = "[center]Time until level reset: %d[/center]" % snappedf((time - timer), 1)

func on_end_bttn_press():
	Sfx.play_sound_ui_number(0)
	on_quit_request.emit()

func on_reset_bttn_press():
	Sfx.play_sound_ui_number(0)
	on_reset_request.emit()
