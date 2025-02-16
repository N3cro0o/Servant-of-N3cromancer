extends Control

#region Variables

@onready var color_items: ColorRect = $MarginContainer/VBoxContainer/Items/ColorRect
@onready var color_main: ColorRect = $MarginContainer/VBoxContainer/MainBody/ColorRect
@onready var color_buttons: ColorRect = $MarginContainer/VBoxContainer/Buttons/ColorRect
@onready var coins_pause_item: PauseItem = $MarginContainer/VBoxContainer/Items/ItemsContainer/Coins

#endregion

#region Signals

signal on_reset_request
signal on_game_start_request
signal on_quit_request

#endregion

# Basic Godot functions
func _ready():
	color_main.visible = false
	color_items.visible = false
	color_buttons.visible = false
	visibility_changed.connect(on_changing_visibility)

func on_changing_visibility():
	coins_pause_item.set_value("%d(%d)" % [ScM.coins_game, ScM.coins_game + ScM.coins])

# Button functions
func on_end_bttn_press():
	Sfx.play_sound_ui_number(0)
	on_quit_request.emit()

func on_reset_bttn_press():
	Sfx.play_sound_ui_number(0)
	on_reset_request.emit()

func on_pause_bttn_press():
	Sfx.play_sound_ui_number(0)
	on_game_start_request.emit()
