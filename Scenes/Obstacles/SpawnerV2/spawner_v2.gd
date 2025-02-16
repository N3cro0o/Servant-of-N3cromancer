class_name SpawnerBasicV2 extends Node2D

const PICKUP_PATH = "res://Scenes/PowerUpsAndPickUps/Base/pick_up_base.tscn"
const PICKUP_BASE = preload(PICKUP_PATH)

#region Variables
@export var active = false:
	set(b):
		if obstacle_data != null:
			active = b
			update_packed_scenes()
@export var obstacle_data: StageEnemyData
@export_range(0, 5) var spawn_delay = 3.0
## Minimum weight needed for no-repeating
@export var weight_threshold = 3
@export_group("Spawn Points")
@export_range(1, 5) var spawn_points: int = 1:
	set(points):
		spawn_points = points
		update_spawners()
@export var distance_between: float = 0:
	set(dist):
		distance_between = dist
		update_spawners()
@export var spawner_offset := Vector2.ZERO:
	set(vec):
		spawner_offset = vec
		update_spawners()

@onready var spawn_points_arr: Array[Node2D] = [
	$"Spawners/1", $"Spawners/2", $"Spawners/3", $"Spawners/4", $"Spawners/5"]
@onready var spawn_timer_arr: Array[Timer] = [$"1", $"2", $"3", $"4", $"5"]

var spawn_weight: Array[int] = [0,0,0,0,0]
# Scenes vars
var packed_scenes_array: Array[PackedScene]
var other_scenes_array: Array[PackedScene]
var boss_scenes_array: Array[PackedScene]
#endregion

# Basic Godot functions
func _ready():
	if GameScene.instance != null:
		# Wait for level inicialization
		await GameScene.instance.on_level_start
	GmM.on_paused.connect(on_paused)
	update_spawners()
	active = true

# Spawn point functions
func set_obstacle_data(data: StageEnemyData):
	obstacle_data = data
	active = true

func update_spawners():
	for i in 5:
		if i < spawn_points:
			spawn_points_arr[i].visible = true
		else:
			spawn_points_arr[i].visible = false
	update_position()

func update_position():
	var offset = 0
	if spawn_points % 2 == 0:
		var half_offset = distance_between / 2
		offset = half_offset
		for i in 5:
			spawn_points_arr[i].position = position + spawner_offset + Vector2(offset, 0)
			if offset > 0:
				offset = -offset
			else:
				offset = half_offset + distance_between * (i / 2 + 1)
	else:
		offset = 0
		for i in 5:
			spawn_points_arr[i].position = position + spawner_offset + Vector2(offset, 0)
			if offset > 0:
				offset = -offset
			else:
				offset = distance_between * (i / 2 + 1)

# Spawning functions
func update_packed_scenes():
	# Can live without it, just resize other arrays
	packed_scenes_array.resize(0)
	other_scenes_array.resize(0)
	boss_scenes_array.resize(0)
	spawn_weight = [0,0,0,0,0]
	var scene_holder: Array[String] = []
	scene_holder = _add_packed_scenes(1, obstacle_data.data_1, scene_holder)
	scene_holder = _add_packed_scenes(2, obstacle_data.data_2, scene_holder)
	scene_holder = _add_packed_scenes(3, obstacle_data.data_3, scene_holder)
	scene_holder = _add_packed_scenes(4, obstacle_data.data_4, scene_holder)
	scene_holder = _add_packed_scenes(5, obstacle_data.data_5, scene_holder)
	print_rich("[hint=%s]Packed count = %d[/hint]" % [name, packed_scenes_array.size()])

func _add_packed_scenes(num: int, data_arr, scene_holder) -> Array[String]:
	for i in data_arr:
		var index = scene_holder.find(i.resource_path)
		if index == -1:
			i.spawner_index = scene_holder.size()
			scene_holder.push_back(i.resource_path)
			var scene = load(i.scene_directory)
			if i.type == 3:
				other_scenes_array.push_back(scene)
			else:
				i.spawner_index = index
				packed_scenes_array.push_back(scene)
		spawn_weight[num] += i.weight
	return scene_holder

# Paused functions
func on_paused(paused):
	pass
