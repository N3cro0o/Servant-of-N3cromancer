class_name SaveManager extends Node

const SAVE_PATH = "user://czacha_zapis.json"

var data = {
	"highscore" : 0,
	"coins" : 0,
	"current_skul" : 0,
	# Unlock endless, nimble skull, custom Line, inventory 1
	"unlocks_shop" : [false, false, false, false]
}

signal on_save_completed
signal on_load_completed

func _ready():
	if check_path(SAVE_PATH):
		load_data()
	else:
		reset_data()

func reset_data():
	data["highscore"] = 0
	data["coins"] = 0
	data["current_skul"] = 0
	var size = data["unlocks_shop"].size()
	for i in size:
		data["unlocks_shop"][i] = false

func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json = JSON.stringify(data,"   \t")
	file.store_string(json)
	file.close()
	print_rich("[hint=SaveManager]Data saved[/hint] at %s" % Time.get_time_dict_from_system())
	on_save_completed.emit()

func check_path(path : String):
	if FileAccess.file_exists(path):
		return true
	return false

func load_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json = file.get_as_text()
	data = JSON.parse_string(json)
	file.close()
	print_rich("[hint=SaveManager]Data loaded from file[/hint] at %s" % Time.get_time_dict_from_system())
	# Load data
	ScM.coins_game = data["coins"]
	var upgrade_names : String = ""
	for i in 3:
		var b = data["unlocks_shop"][i]
		if b:
			GmM.items[i].on_buy()
			upgrade_names += "%s " % GmM.items[i].name
	print_rich("[hint=SaveManager]Data loaded[/hint]\n%s\n\n" % upgrade_names)
	on_load_completed.emit()
