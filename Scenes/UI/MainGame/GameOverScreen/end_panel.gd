class_name GameOverScreen extends Control

const descritpion : String = "Score: %d\nCoins: %d\nDistance: %d meters"
const descritpion_score : String = "New Hi Score! %d\nCoins: %d\nDistance: %d m"

#region Variables

@export_range(0, 25) var time = 10.0
@export_range(0, 1.5) var modulate_time: float = 0.5
@onready var name_label = $Margin/Box/Upper/YouDiedBruhLabel
@onready var desc_label = $Margin/Box/Middle/VB/DescriptionLabel
@onready var reset_button : Button = $Margin/Box/Bottom/VBoxContainer/ResetButton

var timer = 0
var modulate_timer: float = 0
var lock_timer: bool = false

#endregion
#region Signals

signal on_reset_request
signal on_quit_request

#endregion

# Basic Godot functions
func _process(delta):
	if visible:
		if !lock_timer:
			timer += delta
			if(timer >= time):
				on_reset_request.emit()
			reset_button.text = "RESET (%d)" % snappedf((time - timer), 1)
		else:
			timer = 0
			reset_button.text = "RESET"
		# Modulate
		modulate_timer += delta * (1 / modulate_time)
		if modulate_timer > 1:
			modulate_timer = 1
		modulate = Color(modulate, modulate_timer)
	else:
		lock_timer = false

# Button functions
func on_end_bttn_press():
	Sfx.play_sound_ui_number(0)
	on_quit_request.emit()

func on_reset_bttn_press():
	Sfx.play_sound_ui_number(0)
	on_reset_request.emit()

# Update functions
func update_desc():
	var arr = [ScM.score, ScM.coins, snappedf(ScM.distance, 1)]
	if ScM.score > ScM.highscore:
		desc_label.text = descritpion_score % arr
	else:
		desc_label.text = descritpion % arr
	visible = true
	modulate = Color(modulate, 0)
	SvM.save_data()

func hold_timer_gui_input(_event):
	if _event is InputEventScreenTouch && _event.is_pressed():
		lock_timer = true
