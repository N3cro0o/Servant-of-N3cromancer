extends Control

#region Variables

@export var skip_cost = 20
@export var skip_add = 10

@onready var main := $Margin/VBox/Main
# Body part
@onready var body = $Margin/VBox/Main/PlayerCustomization/Margin/ScrollBox/VBox/Body
@onready var body_label = $Margin/VBox/Main/PlayerCustomization/Margin/ScrollBox/VBox/Body/Box/Buttons/Box/RichTextLabel
@onready var body_texture = $Margin/VBox/Main/PlayerCustomization/Margin/ScrollBox/VBox/Body/Box/Texture
# Line part
@onready var line = $Margin/VBox/Main/PlayerCustomization/Margin/ScrollBox/VBox/Line
@onready var line_color_grid = $Margin/VBox/Main/PlayerCustomization/Margin/ScrollBox/VBox/Line/Box/Margin/Grid
# Options
@onready var master_slider = $Margin/VBox/Main/Options/Margin/ScrollBox/VBox/SoundSlider/Master/MasterSlider
@onready var music_slider: HSlider = $Margin/VBox/Main/Options/Margin/ScrollBox/VBox/SoundSlider/Music/MusicSlider
@onready var obstacle_slider: HSlider = $Margin/VBox/Main/Options/Margin/ScrollBox/VBox/SoundSlider/Obstacles/ObstacleSlider
@onready var ui_slider: HSlider = $Margin/VBox/Main/Options/Margin/ScrollBox/VBox/SoundSlider/UI/UISlider
@onready var particle_slider: HSlider = $Margin/VBox/Main/Options/Margin/ScrollBox/VBox/Graphics/Particle/ParticleSlider
@onready var version_label: Label = $Margin/VBox/Main/Options/Margin/ScrollBox/VBox/Label
@onready var debug_label_button: CheckButton = $Margin/VBox/Main/Options/Margin/ScrollBox/VBox/VBoxContainer/DebugLabelButton
@onready var hud_button: CheckButton = $Margin/VBox/Main/Options/Margin/ScrollBox/VBox/VBoxContainer/PermHUDButton
# Mute
@onready var mute_master: TextureButton = $Margin/VBox/Main/Options/Margin/ScrollBox/VBox/SoundSlider/Master/Mute
@onready var mute_music: TextureButton = $Margin/VBox/Main/Options/Margin/ScrollBox/VBox/SoundSlider/Music/Mute
@onready var mute_obstacle: TextureButton = $Margin/VBox/Main/Options/Margin/ScrollBox/VBox/SoundSlider/Obstacles/Mute
@onready var mute_ui: TextureButton = $Margin/VBox/Main/Options/Margin/ScrollBox/VBox/SoundSlider/UI/Mute

# Tasks
@onready var task_grid: TaskGrid = $Margin/VBox/Main/Tasks/Margin/V/Box/TaskGrid
@onready var task_label: Label = $Margin/VBox/Main/Tasks/Margin/V/Options/Completed
@onready var text_task1: Label = $Margin/VBox/Main/Tasks/Margin/V/Options/Text1
@onready var text_task2: Label = $Margin/VBox/Main/Tasks/Margin/V/Options/Text2
@onready var text_task3: Label = $Margin/VBox/Main/Tasks/Margin/V/Options/Text3

# Difficulties
@onready var speed_box: VBoxContainer = $Margin/VBox/Main/PlayerCustomization/Margin/ScrollBox/VBox/Diff/Speed
@onready var speed_slider: HSlider = $Margin/VBox/Main/PlayerCustomization/Margin/ScrollBox/VBox/Diff/Speed/SpeedSlider

var active_tab = 0
var active_body = 0
var bttn: Button
var skip_tween_g: Tween
var skip_tween_b: Tween
var lock_sliders = false
var color_skip = Color("ffc7b9")
var color_reroll = Color("cfddb1")

# Secrets
var secret_buffer: Array[int]
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
	lock_sliders = true
	master_slider.value = SvM.data["volume_master"]
	mute_master.button_pressed = !SvM.data["master_muted"]
	music_slider.value = SvM.data["volume_music"]
	mute_music.button_pressed = !SvM.data["music_muted"]
	obstacle_slider.value = SvM.data["volume_obstacle"]
	mute_obstacle.button_pressed = !SvM.data["obstacle_muted"]
	ui_slider.value = SvM.data["volume_ui"]
	mute_ui.button_pressed = !SvM.data["ui_muted"]
	lock_sliders = false
	particle_slider.value = SvM.return_particle_amount()
	debug_label_button.button_pressed = GmM.debug_label_visible
	hud_button.button_pressed = GmM.show_game_ui
#region Difficulties
	# Speed
	speed_slider.max_value = GmM.max_extra_speed_level
	speed_slider.value = GmM.extra_speed_level
	if speed_slider.max_value == 0: speed_box.visible = false
#endregion
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
		if $Logs.visible:
			$Logs.visible = false
			return
		return_button_pressed()
	if what == NOTIFICATION_FOCUS_ENTER:
		GmM.paused = false
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		GmM.paused = false

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
	update_buffer(num)

# Customisation functions
func update_customisattion_body_data():
	var data = GmM.body_holder_array[active_body]
	body_label.text = "[center]%s[/center]" % [data.body_name + " Skul"]
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

func disable_audio_slider(b: bool, num: int):
	b = !b
	match num:
		0:
			master_slider.editable = !b
			Sfx.set_bus_muted("master", b)
			SvM.mute_volume_master(b)
			if b:
				master_slider.modulate = Color("CCCCCCAA")
			else:
				master_slider.modulate = Color("FFFFFFFF")
		1:
			music_slider.editable = !b
			Sfx.set_bus_muted("music", b)
			SvM.mute_volume_music(b)
			if b:
				music_slider.modulate = Color("CCCCCCAA")
			else:
				music_slider.modulate = Color("FFFFFFFF")
		2:
			obstacle_slider.editable = !b
			Sfx.set_bus_muted("obstacle", b)
			SvM.mute_volume_obstacle(b)
			if b:
				obstacle_slider.modulate = Color("CCCCCCAA")
			else:
				obstacle_slider.modulate = Color("FFFFFFFF")
		3:
			ui_slider.editable = !b
			Sfx.set_bus_muted("ui", b)
			SvM.mute_volume_ui(b)
			if b:
				ui_slider.modulate = Color("CCCCCCAA")
			else:
				ui_slider.modulate = Color("FFFFFFFF")
func change_master_bus_volume(num):
	if lock_sliders:
		return
	Sfx.update_bus_volume("master", num)
	SvM.update_volume_master(num)

func change_music_bus_volume(num):
	if lock_sliders:
		return
	Sfx.update_bus_volume("music", num)
	SvM.update_volume_music(num)

func change_obstacle_bus_volume(num):
	if lock_sliders:
		return
	Sfx.update_bus_volume("obstacle", num)
	SvM.update_volume_obstacle(num)

func change_ui_bus_volume(num):
	if lock_sliders:
		return
	Sfx.update_bus_volume("UI", num)
	SvM.update_volume_ui(num)
	
func change_particle_amount(num):
	# Add different percent text
	particle_slider.tooltip_text = str(num)
	SvM.update_particles_amount(num)

func debug_label_toggle(b):
	GmM.debug_label_visible = b

func show_game_ui(b):
	GmM.show_game_ui = b
	SvM.update_show_hud(b)

# UI functions
func update_task_label():
	task_label.text = "Tasks completed: %d\nTasks skipped: %d" % [SvM.return_tasks_completed(),\
		SvM.return_tasks_skipped()]

# Diff functions
func udate_max_speed(val: float):
	GmM.extra_speed_level = val

# Credits buttons
func itch_button_credits():
	OS.shell_open("https://n3cro0odev.itch.io/servant-of-nekromanter")

func twitter_button_credits():
	OS.shell_open("https://x.com/N3cro0oDev")

# Secret functions
func update_buffer(num: int):
	secret_buffer.push_front(num)
	if secret_buffer.size() > 8:
		secret_buffer.pop_back()
	secret_codes()

func secret_codes():
	# Codes from go [last press, second to last, [...], first press]
	if secret_buffer == [1, 2, 0, 2, 0, 2, 0, 2]:
		print("Web mode: ", !GmM.web_development)
		Sfx.play_sound_ui_number(1)
		GmM.web_development = !GmM.web_development
		secret_buffer.clear()
	if secret_buffer == [0,1,0,1,0,1,0,1]:
		var text := SvM.read_logs()
		if text.is_empty():
			return
		$Logs/Scroll/LogLabel.text = SvM.read_logs()
		$Logs.visible = true
		Sfx.play_sound_ui_number(1)
		secret_buffer.clear()
