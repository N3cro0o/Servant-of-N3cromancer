class_name GM extends Node

#region Variables

@export_category("GUI")
@export_range(0,1) var transition_speed :float = 1
@export_category("Shop")
@export var items : Array[ItemShopData]

@export_category("Game")
## Remember to tick this on while exporting on HTML5, moron[br][b]I know you will forget
@export var web_development = false
## NOT CHANCE[br]
## Variable used to calculate frequency of pickups, shows mean objects required to spawn a pickup
@export var pickup_spawn_period = 5
@export var max_tasks = 3
@export_group("GameDataArrays")
@export var body_holder_array : Array[PlayerBodyHolder]
@export var scene_array : Array[PackedScene]
@export var obstacle_arr: Array[SpawnObstacleDataHolder]
@export var pickup_arr: Array[SpawnPickupDataHolder]
@export_group("Pause")
## Change this value to change the game speed while paused[br]
## Default = 0.05
@export var paused_slowdown := 0.02

@onready var screen_black := $Control/BlackScreen
@onready var slow_mo_timer: Timer = $"Slow-MoTimer"

# Colour stuff
var black_colour = Color.BLACK
var line_color_array = [Color("ffffff"), Color("ed0e4c"), Color("3b0ae5"), Color("1ec622"),
	Color("ff53c5"), Color("cda000")]

# Game data 
var body_array : Array[PackedScene]
var curr_scene : Node
var transition_iterat = 0
var window_fix: float
var debug_label_visible = false
var extra_speed_level: int = 0:
	set(val_i):
		extra_speed_level = val_i
		real_game_speed = 1.0 + pow(1.2137, pow(val_i, 1.1)) - 1
		game_speed = real_game_speed
		SvM.update_extra_speed(val_i)

# Save Data
var endless_unlock = true
var line_customization_unlock = false
var current_body = 0
var line_color = 0
var inventory_space = 0
var inventory_space_single = 0
var show_game_ui = false
var max_extra_speed_level: int = 0

# Obstacles
var ready_obstacle_arr: Array[PackedScene]

# Game time stuff. For example a variable responisble for pausing game
var paused := false:
	set(value):
		if !is_node_ready():
			return
		var volume = SvM.data["volume_music"];
		paused = value
		on_paused.emit(paused)
		if (paused):
			# Change this value to change the game speed while paused.
			# Default = 0.05
			game_speed = paused_slowdown
			game_speed_interpolation_check = false
			slow_mo_timer.paused = true
			Sfx.update_bus_volume("Music", volume * 0.01)
		else:
			if !real_game_speed_interpolation_check:
				game_speed = slow_mo_game_speed
			else:
				game_speed = real_game_speed
			game_speed_interpolation_check = real_game_speed_interpolation_check
			slow_mo_timer.paused = false
			Sfx.update_bus_volume("Music", volume)
var game_speed := 1.0
var slow_mo_game_speed := 1.0
var real_game_speed := 1.0
var game_speed_interpolation_check = true
var real_game_speed_interpolation_check = true:
	set(b):
		real_game_speed_interpolation_check = b
		game_speed_interpolation_check = b

signal on_paused(b:bool)
signal on_slow_mo(b:bool)
#endregion

# Basic Godot functions
func _ready():
	for x in body_holder_array:
		var body = load(x.body_scene_path)
		body_array.push_back(body)
	black_colour = screen_black.color
	screen_black.color = Color(black_colour, 1)
	transition_iterat = transition_speed * 60
	# Uber Duper Mega Zajebisty fix
	update_window_fix()
	await SvM.on_load_completed
	update_max_tasks()
	# Load obstacles and pickups... for later use
	for data in obstacle_arr:
		ready_obstacle_arr.push_back(load(data.scene_directory))
	TsM.setup()
	if !SvM.data["tutorial"]:
		change_scene(4)
	else:
		transition_screen_out()

func _physics_process(delta: float) -> void:
	if game_speed_interpolation_check:
		game_speed += game_speed * delta
		slow_mo_game_speed = real_game_speed
		# second emit if speed are the same
		if game_speed >= real_game_speed:
			on_slow_mo.emit(false)
			game_speed_interpolation_check = false
			game_speed = real_game_speed

func _notification(what):
	# Quit game
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		paused = true
	if what == NOTIFICATION_APPLICATION_PAUSED:
		paused = true

# Main game functions
func update_line_color(color : int):
	line_color = color
	SvM.update_line_color(color)

func change_scene(scene_to_go : int):
	if scene_to_go == 0:
		SvM.tutorial_complete()
		TsM.fill()
	await transition_screen_in()
	paused = false
	after_game_over_logic(-1)
	var scene = scene_array[scene_to_go]
	get_tree().change_scene_to_packed(scene)
	curr_scene = get_tree().get_current_scene()
	await transition_screen_out()

func transition_screen_in():
	var i = transition_iterat
	for x in i:
		screen_black.color.a = lerpf(screen_black.color.a, black_colour.a, float(x)/i)
		await Engine.get_main_loop().process_frame

func transition_screen_out():
	var i = transition_iterat
	for x in i:
		screen_black.color.a = lerpf(screen_black.color.a, 0, float(x)/i)
		await Engine.get_main_loop().process_frame

func after_game_over_logic(num := 0):
	GmM.paused = false
	GmM.stop_slow_mo()
	GmM.game_speed = GmM.real_game_speed
	match num:
		0:
			ScM.finalize_level_score()
		-1:
			ScM.reset_score()
	TsM.validate_tasks()

# Shop functions
func sort_by_shop_category(a : ItemShopData, b : ItemShopData):
	if a.category < b.category:
		return true
	return false

# Slow-mo functions
func start_slow_mo(time: float, force: float):
	if (force <= 0 or force > 1) and time <= 0:
		return
	game_speed *= force
	slow_mo_game_speed = game_speed
	slow_mo_timer.start(time);
	real_game_speed_interpolation_check = false
	on_slow_mo.emit(true)

func stop_slow_mo():
	real_game_speed_interpolation_check = true

# Save data functions
func update_max_tasks():
	@warning_ignore("integer_division")
	TsM.max_tasks = min(max_tasks, SvM.return_tasks_all() / 5 + 1)

func reset_save_data():
	SvM.reset_data()
	endless_unlock = true
	line_customization_unlock = false
	current_body = 0 
	line_color = 0
	inventory_space = 0
	inventory_space_single = 0
	SvM.save_data()
	SvM.reset_tasks()
	# Tasks
	TsM.reset()
	# Play the tutorial again
	GmM.change_scene(4)

# Obstacle functions
func return_loaded_obstacle_by_id(id: int) -> PackedScene:
	var obs_id = 1 # Basic bow obstacle
	for i in obstacle_arr.size():
		if obstacle_arr[i].obstacle_id == id:
			obs_id = i
			break
	return ready_obstacle_arr[obs_id]

# Prefs functions
func update_window_fix():
	window_fix = float(get_viewport().get_visible_rect().size.x - 1080) / 2.0
