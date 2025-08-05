@tool
class_name StageEnemyData extends Resource

@export_group("Obstacles")
@export_range(1, 5) var spawn_points: int = 1
@export var data_1: Array[SpawnObstacleDataHolder]:
	set(arr):
		if spawn_points >= 1:
			data_1 = arr
		else:
			data_1 = []
@export var data_2: Array[SpawnObstacleDataHolder]:
	set(arr):
		if spawn_points >= 2:
			data_2 = arr
		else:
			data_2 = []
@export var data_3: Array[SpawnObstacleDataHolder]:
	set(arr):
		if spawn_points >= 3:
			data_3 = arr
		else:
			data_3 = []
@export var data_4: Array[SpawnObstacleDataHolder]:
	set(arr):
		if spawn_points >= 4:
			data_4 = arr
		else:
			data_4 = []
@export var data_5: Array[SpawnObstacleDataHolder]:
	set(arr):
		if spawn_points == 5:
			data_5 = arr
		else:
			data_5 = []
@export_group("Config")
@export var ignore_static = false
@export var ignore_repeating = false
## Difficulty needed to advance to the boss spawn
@export_range(-1, 100) var difficulty_threshold := 10.0
## Picking other non-static obstacle after getting static obstacle multiple times in a row
@export_range(0, 1) var static_skip_chance :float = 0.35
@export_range(1, 5) var spawn_delay_min :float = 3:
	set(d):
		if d <= spawn_delay_max:
			spawn_delay_min = d
@export_range(2, 6) var spawn_delay_max :float = 3:
	set(d):
		if d >= spawn_delay_min:
			spawn_delay_max = d
@export_group("Other")
@export var bosses : Array[SpawnObstacleDataHolder]
@export var pickups : Array[SpawnPickupDataHolder]
@export_group("Style")
@export var backround: Texture2D = preload("res://Images/BG/BG.png")
@export var music: MusicHolder = preload("res://SFX/MusicData/main_game.tres")
