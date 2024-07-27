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
@export var scene_array : Array[PackedScene]
@onready var screen_black := $Control/BlackScreen
var black_colour = Color.BLACK
var curr_scene : Node
var transition_iterat = 0

# Save Data
var endless_unlock = false
#endregion

#region Method
func _ready():
	black_colour = screen_black.color
	screen_black.color = Color(black_colour, 0)
	transition_iterat = transition_speed * 60

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
	SvM.save_data()

func change_scene(scene_to_go : int):
	await transition_screen_in()
	after_game_over_logic(-1)
	var scene = scene_array[scene_to_go]
	get_tree().change_scene_to_packed(scene)
	curr_scene = get_tree().get_current_scene()
	await transition_screen_out()
#endregion
