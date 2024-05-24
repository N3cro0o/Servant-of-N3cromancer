class_name GM extends Node

const GAME_SCENE = preload("res://Scenes/GameScenes/GameScene/game_scene.tscn")

#region Variables
## NOT CHANCE[br]
## Variable used to calculate frequency of pickups, shows mean objects required to spawn a pickup
@export var pickup_spawn_period = 5
var curr_scene : Node2D
#endregion

#region Method
func _ready():
	var x = get_tree().root.get_child_count()
	curr_scene = get_tree().root.get_child(x - 1) as GameScene
	if curr_scene != null:
		curr_scene.on_failing_level.connect(reload_scene)

func reload_scene():
	# Bruh, ONLY 10 errors... WHAT COULD GO WRONG????
	curr_scene.on_failing_level.disconnect(reload_scene)
	curr_scene.queue_free()
	var sc = GAME_SCENE.instantiate()
	curr_scene = sc
	get_tree().root.call_deferred("add_child", sc)
	curr_scene.on_failing_level.connect(reload_scene)
	ScM.reset_score()
#endregion
