class_name SaveManager extends Node

const SAVE_PATH = "user://czacha_zapis.json"

@export var save_version = 1.1

var data = {
	# Control version, update after every major change
	"version" : 0,
	"highscore" : 0,
	"coins" : 0,
	"current_skul" : 0,
	"line_color" : 0,
	# Unlock nimble skull, custom Line, inventory 1
	"unlocks_shop" : [false, false, false],
	# Options
	"volume_master" : 1
}

signal on_save_completed
signal on_load_completed

func _ready():
	if check_path(SAVE_PATH):
		load_data()
	else:
		reset_data()

#region Save System

func reset_data():
	data["version"] = save_version
	data["highscore"] = 0
	data["coins"] = 0
	data["current_skul"] = 0
	for i in GmM.items.size():
		data["unlocks_shop"][i] = false
	data["line_color"] = 0
	# Options data
	data["volume_master"] = 1

func save_data():
	if OS.is_userfs_persistent():
		var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
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

func load_data():
	if OS.is_userfs_persistent():
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
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
		print_rich("[hint=SaveManager]Data loaded[/hint]\n%s\n\n" % upgrade_names)
		# Load options data
			# Volume master
		Sfx.update_bus_volume("master", data["volume_master"])
	on_load_completed.emit()

#endregion

func update_player_body(body_id : int):
	data["current_skul"] = body_id

func update_score(coin, score):
	data["highscore"] = score
	data["coins"] = coin

func update_line_color(color : int):
	data["line_color"] = color

func update_upgrade_shop_bought(id : int):
	data["unlocks_shop"][id] = true

func update_volume_master(val : float):
	data["volume_master"] = val
