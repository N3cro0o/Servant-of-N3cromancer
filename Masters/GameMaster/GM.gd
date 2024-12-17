class_name GM extends Node

#region Variables

@export_category("GUI")
@export_range(0,1) var transition_speed :float = 1
@export_category("Shop")
@export var items : Array[ItemShopData]

@export_category("Game")
## NOT CHANCE[br]
## Variable used to calculate frequency of pickups, shows mean objects required to spawn a pickup
@export var pickup_spawn_period = 5
@export var body_holder_array : Array[PlayerBodyHolder]
@export var scene_array : Array[PackedScene]
@onready var screen_black := $Control/BlackScreen

# Colour stuff
var black_colour = Color.BLACK
var line_color_array = [Color("ffffff"), Color("ed0e4c"), Color("3b0ae5"), Color("1ec622"),
	Color("ff53c5"), Color("cda000")]

# Game data 
var body_array : Array[PackedScene]
var curr_scene : Node
var transition_iterat = 0

# Save Data
var endless_unlock = true
var line_customization_unlock = false
var current_body = 0
var line_color = 0
var inventory_space = 0

#endregion

# Basic Godot functions
func _ready():
	for x in body_holder_array:
		var body = load(x.body_scene_path)
		body_array.push_back(body)
	black_colour = screen_black.color
	screen_black.color = Color(black_colour, 0)
	transition_iterat = transition_speed * 60

# Main game functions
func update_line_color(color : int):
	line_color = color
	SvM.update_line_color(color)

func change_scene(scene_to_go : int):
	await transition_screen_in()
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
	match num:
		0:
			ScM.finalize_level_score()
		-1:
			ScM.reset_score()

# Shop functions
func sort_by_shop_category(a : ItemShopData, b : ItemShopData):
	if a.category < b.category:
		return true
	return false

# Save data functions
func reset_save_data():
	SvM.reset_data()
	endless_unlock = true
	line_customization_unlock = false
	current_body = 0
	line_color = 0
	inventory_space = 0
	SvM.save_data()
