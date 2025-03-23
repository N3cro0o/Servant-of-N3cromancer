extends Control

#region Variables

@export var skip_cost = 20
@export var skip_add = 10

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
@onready var particle_slider: HSlider = $Margin/VBox/Main/Options/Margin/VBox/Graphics/Particle/ParticleSlider
@onready var version_label: Label = $Margin/VBox/Main/Options/Margin/VBox/Label
@onready var debug_label_button: CheckButton = $Margin/VBox/Main/Options/Margin/VBox/Graphics/DebugLabelButton
# Tasks
@onready var task_grid: TaskGrid = $Margin/VBox/Main/Tasks/Margin/V/Box/TaskGrid
@onready var task_label: Label = $Margin/VBox/Main/Tasks/Margin/V/Options/Completed
@onready var text_task1: Label = $Margin/VBox/Main/Tasks/Margin/V/Options/Text1
@onready var text_task2: Label = $Margin/VBox/Main/Tasks/Margin/V/Options/Text2
@onready var text_task3: Label = $Margin/VBox/Main/Tasks/Margin/V/Options/Text3

var active_tab = 0
var active_body = 0
var bttn: Button
var skip_tween_g: Tween
var skip_tween_b: Tween
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
	particle_slider.value = SvM.return_particle_amount()
	debug_label_button.button_pressed = GmM.debug_label_visible
	task_grid.update_data()
	update_task_label()
	if TsM.task_arr.size() >= 1:
		text_task1.text = "Task 1. %s" % [TsM.task_arr[0].task_name()]
		$Margin/VBox/Main/Tasks/Margin/V/Options/Buttons1/Skip.pressed.\
			connect(skip_task.bind(0))
		$Margin/VBox/Main/Tasks/Margin/V/Options/Buttons1/Reroll.pressed.\
			connect(reroll_task.bind(0))
	else:
		text_task1.text = ""
		$Margin/VBox/Main/Tasks/Margin/V/Options/Buttons1.visible = false
	if TsM.task_arr.size() >= 2:
		text_task2.text = "Task 2. %s" % [TsM.task_arr[1].task_name()]
		$Margin/VBox/Main/Tasks/Margin/V/Options/Buttons2/Skip.pressed.\
			connect(skip_task.bind(1))
		$Margin/VBox/Main/Tasks/Margin/V/Options/Buttons2/Reroll.pressed.\
			connect(reroll_task.bind(1))
	else:
		text_task2.text = ""
		$Margin/VBox/Main/Tasks/Margin/V/Options/Buttons2.visible = false
	if TsM.task_arr.size() >= 3:
		text_task3.text = "Task 3. %s" % [TsM.task_arr[2].task_name()]
		$Margin/VBox/Main/Tasks/Margin/V/Options/Buttons3/Skip.pressed.\
			connect(skip_task.bind(2))
		$Margin/VBox/Main/Tasks/Margin/V/Options/Buttons3/Reroll.pressed.\
			connect(reroll_task.bind(2))
	else:
		text_task3.text = ""
		$Margin/VBox/Main/Tasks/Margin/V/Options/Buttons3.visible = false
	# Unlocks
	set_unlockable_panels()
	update_customisattion_body_data()
	if GmM.web_development:
		$Margin/VBox/Main/Options/Margin/VBox/WebAd.visible = true

func _notification(what):
	# Return to Main Menu
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		return_button_pressed()

# Control functions
func skip_task(id: int):
	if ScM.coins_game >= skip_cost + skip_add * SvM.return_tasks_skipped():
		ScM.coins_game -= skip_cost + skip_add * SvM.return_tasks_skipped()
		TsM.skip_task(TsM.task_arr[id])
		task_grid.update_data()
		update_task_label()
	else:
		if skip_tween_g != null:
			skip_tween_g.kill()
		if skip_tween_b != null:
			skip_tween_b.kill()
		if bttn != null:
			bttn.modulate = Color.WHITE
		match id:
			0:
				tween_refuse($Margin/VBox/Main/Tasks/Margin/V/Options/Buttons1/Skip)
			1:
				tween_refuse($Margin/VBox/Main/Tasks/Margin/V/Options/Buttons2/Skip)
			2:
				tween_refuse($Margin/VBox/Main/Tasks/Margin/V/Options/Buttons3/Skip)

func reroll_task(id: int):
	if !TsM.task_arr[id].rerolled:
		TsM.reroll_task(TsM.task_arr[id])
		task_grid.update_data() 
		update_task_label()
	else:
		if skip_tween_g != null:
			skip_tween_g.kill()
		if skip_tween_b != null:
			skip_tween_b.kill()
		if bttn != null:
			bttn.modulate = Color.WHITE
		match id:
			0:
				tween_refuse($Margin/VBox/Main/Tasks/Margin/V/Options/Buttons1/Reroll)
			1:
				tween_refuse($Margin/VBox/Main/Tasks/Margin/V/Options/Buttons2/Reroll)
			2:
				tween_refuse($Margin/VBox/Main/Tasks/Margin/V/Options/Buttons3/Reroll)

func tween_refuse(button: Button):
	bttn = button
	bttn.modulate = Color(1,0,0)
	skip_tween_g = get_tree().create_tween()
	skip_tween_g.tween_property(bttn, "modulate:g", 1, 0.5)
	skip_tween_b = get_tree().create_tween()
	skip_tween_b.tween_property(bttn, "modulate:b", 1, 0.45)

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

# THE SHIT BROKE. YOU CAN ACCESS INDEXES HIGHER THAN THEY CAN BE!!!!!!!!!!
func change_body_object(num : int):
	var start_body = active_body
	active_body += num
	if active_body >= GmM.body_array.size():
		active_body = 0
	elif active_body < 0:
		active_body = GmM.body_array.size() - 1
	if !GmM.body_holder_array[active_body].body_unlocked:
		active_body = start_body
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

func change_particle_amount(num):
	# Add different percent text
	particle_slider.tooltip_text = str(num)
	SvM.update_particles_amount(num)

func debug_label_toggle(b):
	GmM.debug_label_visible = b

# UI functions
func update_task_label():
	task_label.text = "Tasks completed: %d\nTasks skipped: %d" % [SvM.return_tasks_completed(),\
		SvM.return_tasks_skipped()]

# Credits buttons
func itch_button_credits():
	OS.shell_open("https://n3cro0odev.itch.io")

func twitter_button_credits():
	OS.shell_open("https://x.com/N3cro0oDev")
