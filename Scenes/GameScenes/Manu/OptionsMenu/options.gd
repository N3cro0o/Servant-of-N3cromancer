extends Control

#region Variables

@onready var main := $Margin/VBox/Main
# Body part
@onready var body = $Margin/VBox/Main/PlayerCustomization/Margin/VBox/Body
@onready var body_label = $Margin/VBox/Main/PlayerCustomization/Margin/VBox/Body/Box/RichTextLabel
@onready var body_texture = $Margin/VBox/Main/PlayerCustomization/Margin/VBox/Body/Box/Texture
# Line part
@onready var line = $Margin/VBox/Main/PlayerCustomization/Margin/VBox/Line
@onready var line_color_grid = $Margin/VBox/Main/PlayerCustomization/Margin/VBox/Line/Box/Margin/Grid
# Options
@onready var master_slider = $Margin/VBox/Main/Options/Margin/VBox/SoundSlider/MasterSlider
@onready var version_label: Label = $Margin/VBox/Main/Options/Margin/VBox/Label

var active_tab = 0
var active_body = 0

#endregion

# Basic Godot functions
func _ready():
	active_body = GmM.current_body
	version_label.text = "Version " + ProjectSettings.get_setting("application/config/version")
	for i in line_color_grid.get_child_count():
		var button = line_color_grid.get_child(i) as Button
		if i == GmM.line_color:
			button.button_pressed = true
		var panel = button.get_child(0) as ColorRect
		panel.color = GmM.line_color_array[i]
	master_slider.value = SvM.data["volume_master"]
	# Unlocks
	set_unlockable_panels()
	update_customisattion_body_data()

func _notification(what):
	# Return to Main Menu
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		return_button_pressed()

# Traversing functions
func return_button_pressed():
	SvM.save_data()
	GmM.change_scene(0)
	Sfx.play_sound_ui_number(0)

func set_unlockable_panels():
	for child in line.get_children():
		child.visible = GmM.line_customization_unlock

func on_change_tab(num : int):
	Sfx.play_sound_ui_number(0)
	main.set_current_tab(num)
	active_tab = num
	main.queue_redraw()

# Customisation functions
func update_customisattion_body_data():
	var data = GmM.body_holder_array[active_body]
	body_label.text = data.body_name + " Skul"
	body_texture.texture = data.body_image
	body_texture.modulate = data.body_color
	GmM.current_body = active_body

func change_body_object(num : int):
	var start_body = active_body
	active_body += num
	while !GmM.body_holder_array[active_body].body_unlocked:
		active_body += num
		if active_body >= GmM.body_array.size():
			active_body = 0
		elif active_body < 0:
			active_body = GmM.body_array.size() - 1
		if active_body == start_body:
			break
	SvM.update_player_body(active_body)
	update_customisattion_body_data()
	Sfx.play_sound_ui_number(0)

func player_line_color_change(color : int):
	GmM.update_line_color(color)

# Options functions
func on_game_data_reset():
	GmM.reset_save_data()
	set_unlockable_panels()
	Sfx.play_sound_ui_number(0)

func change_master_bus_volume(num):
	Sfx.update_bus_volume("master", num)
	SvM.update_volume_master(num)
