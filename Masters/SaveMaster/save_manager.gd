class_name SaveManager extends Node
# Add tutorial check!
# and start tutorial if it's false
#region Variables & constants
## This is where data is saved... duh\n
## Should change to the save dir, not to the file
const SAVE_DATA_PATH = "user://czacha_zapis.json"
const SAVE_RESOURCE_PATH = "user://resources/"
const SAVE_TASKS_PATH = "tasks/%d.tres"
@export var save_version = 0.4

var data = {
	# Control version, update after every major change
	"version" : 0,
	"highscore" : 0,
	"coins" : 0,
	"tasks_completed": 0,
	"tasks_skipped": 0,
	"current_skul" : 0,
	"line_color" : 0,
	# Unlock nimble skull, custom Line, inventory 1
	"unlocks_shop" : [false, false, false, false],
	# Options
	"volume_master" : 1.0,
	"master_muted": false,
	"volume_music": 1.0,
	"music_muted": false,
	"volume_obstacle": 1.0,
	"obstacle_muted": false,
	"volume_ui": 1.0,
	"ui_muted": false,
	"particles": 0.8,
	"tutorial": false,
	"show_game_ui": false,
	# Diffs
	"extra_speed": 0
}

#endregion
#region Signals

signal on_save_completed
signal on_load_completed

#endregion

func _ready():
	if check_path(SAVE_DATA_PATH):
		load_data()
	else:
		reset_data()
	# Create task directory
	DirAccess.make_dir_recursive_absolute(SAVE_RESOURCE_PATH + "tasks")

# Save system functions
func reset_data():
	data["version"] = save_version
	data["highscore"] = 0
	data["coins"] = 0
	data["tasks_completed"] = 0
	data["tasks_skipped"] = 0
	data["current_skul"] = 0
	for i in GmM.items.size():
		data["unlocks_shop"][i] = false
	data["line_color"] = 0
	# Options data
	data["volume_master"] = 1.0
	data["master_muted"] = false
	data["volume_music"] = 1.0
	data["music_muted"] = false
	data["volume_obstacle"] = 1.0
	data["obstacle_muted"] = false
	data["volume_ui"] = 1.0
	data["ui_muted"] = false
	data["particles"] = 0.8
	data["tutorial"] = false
	data["show_game_ui"] = false
	data["extra_speed"] = 0
	setup_options()
	on_load_completed.emit()

func reset_tasks():
	# Instead of deleting, we can mark them as COMPLETED!!! Works the same
	for i in 3:
		var task = TsM.create_new_task()
		task.completed = true
		ResourceSaver.save(task, SAVE_RESOURCE_PATH + SAVE_TASKS_PATH % i)

## Save game data to local data
func save_data():
	if OS.is_userfs_persistent():
		var file = FileAccess.open(SAVE_DATA_PATH, FileAccess.WRITE)
		var json = JSON.stringify(data,"   \t")
		file.store_string(json)
		file.close()
		print_rich("[hint=SaveManager]Data saved[/hint] at %s" % Time.get_time_dict_from_system())
	on_save_completed.emit()

func check_path(path : String):
	if !OS.is_userfs_persistent():
		return false
	if FileAccess.file_exists(path):
		return true
	return false

func check_data(_path: String) -> bool:
	if OS.is_userfs_persistent():
		var file = FileAccess.open(SAVE_DATA_PATH, FileAccess.READ)
		if file == null:
			return false
		var json = file.get_as_text()
		var data_loaded = JSON.parse_string(json)
		file.close()
		if data_loaded == null:
			return false
		for dat in data_loaded:
			if data[dat] != data_loaded[dat]:
				return false
		return true
	else:
		return false

func load_data():
	if OS.is_userfs_persistent():
		var file = FileAccess.open(SAVE_DATA_PATH, FileAccess.READ)
		var json = file.get_as_text()
		var data_loaded = JSON.parse_string(json)
		file.close()
		for dat in data_loaded:
			data[dat] = data_loaded[dat]
		print_rich("[hint=SaveManager]Data loaded from file[/hint] at %s" % Time.get_time_dict_from_system())
		# Load data
			# Check version
		if data["version"] != save_version:
			print_rich("[hint=SaveManager]Data wrong version[/hint]")
			# Will change for better logic later... hopefully
			reset_data()
			await get_tree().process_frame
			setup_options()
			on_load_completed.emit()
			return
			# Coins and highscore
		ScM.coins_game = data["coins"]
		ScM.highscore = data["highscore"]
			# Upgrades shop
		var upgrade_names : String = ""
		for i in data["unlocks_shop"].size():
			var b = data["unlocks_shop"][i]
			if b:
				GmM.items[i].on_buy()
				upgrade_names += "%s " % GmM.items[i].name
			# Line color
		GmM.line_color = data["line_color"]
			# Current skul body
		GmM.current_body = data["current_skul"]
			# HUD
		GmM.show_game_ui = data["show_game_ui"]
			# Speed
		GmM.extra_speed_level = data["extra_speed"]
		print_rich("[hint=SaveManager]Data loaded[/hint]\n%s\n\n" % upgrade_names)
		await get_tree().process_frame
		# Load options data
		setup_options()
	on_load_completed.emit()

func setup_options():
	# Volume master
	Sfx.update_bus_volume("master", data["volume_master"])
		# Volume music
	Sfx.update_bus_volume("music", data["volume_music"])
		# Volume obstacle
	Sfx.update_bus_volume("obstacle", data["volume_obstacle"])
		# Volume UI
	Sfx.update_bus_volume("UI", data["volume_ui"])
		# Mute buses
	Sfx.set_bus_muted("master", data["master_muted"])
	Sfx.set_bus_muted("music", data["music_muted"])
	Sfx.set_bus_muted("obstacle", data["obstacle_muted"])
	Sfx.set_bus_muted("ui", data["ui_muted"])

# Save resources functions
func check_task(id: int) -> bool:
	return ResourceLoader.exists(SAVE_RESOURCE_PATH + SAVE_TASKS_PATH % id, "TaskHolder")

func save_task(res: Resource, id: int):
	ResourceSaver.save(res, SAVE_RESOURCE_PATH + SAVE_TASKS_PATH % id)

func load_task(id: int) -> TaskHolder:
	var task:TaskHolder = ResourceLoader.load(SAVE_RESOURCE_PATH + SAVE_TASKS_PATH % id, "TaskHolder")
	task.id = id
	return task

# Update game data functions
func update_show_hud(b: bool):
	data["show_game_ui"] = b
	data["version"] = save_version

func update_player_body(body_id : int):
	data["current_skul"] = body_id
	data["version"] = save_version

func update_score(coin, score):
	data["highscore"] = score
	data["coins"] = coin
	data["version"] = save_version

func update_line_color(color : int):
	data["line_color"] = color
	data["version"] = save_version

func update_upgrade_shop_bought(id : int):
	data["unlocks_shop"][id] = true
	data["version"] = save_version

func update_volume_master(val : float):
	data["volume_master"] = val
	data["version"] = save_version

func mute_volume_master(val : bool):
	data["master_muted"] = val
	data["version"] = save_version

func update_volume_music(val : float):
	data["volume_music"] = val
	data["version"] = save_version

func mute_volume_music(val : bool):
	data["music_muted"] = val
	data["version"] = save_version
	
func update_volume_obstacle(val : float):
	data["volume_obstacle"] = val
	data["version"] = save_version

func mute_volume_obstacle(val : bool):
	data["obstacle_muted"] = val
	data["version"] = save_version

func update_volume_ui(val : float):
	data["volume_ui"] = val
	data["version"] = save_version

func mute_volume_ui(val : bool):
	data["ui_muted"] = val
	data["version"] = save_version

func update_particles_amount(val: float):
	data["particles"] = val
	data["version"] = save_version

func tutorial_complete():
	data["tutorial"] = true
	data["version"] = save_version

func update_tasks_completed(num: int):
	data["tasks_completed"] = num
	GmM.update_max_tasks()
	data["version"] = save_version

func update_tasks_skipped(num: int):
	data["tasks_skipped"] = num
	GmM.update_max_tasks()
	data["version"] = save_version

func update_extra_speed(val):
	data["extra_speed"] = val
	data["version"] = save_version

# Return functions
func return_particle_amount() -> float:
	return data["particles"]

func return_tasks_all() -> int:
	return return_tasks_completed() + return_tasks_skipped()

func return_tasks_completed() -> int:
	return data["tasks_completed"]

func return_tasks_skipped() -> int:
	return data["tasks_skipped"]

# Logs
func read_logs(_past = 0) -> String:
	var file = FileAccess.open("user://logs/godot.log", FileAccess.READ)
	var json: String
	if file != null:
		json = file.get_as_text()
		file.close()
	return json
