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
@export_group("")
## Difficulty needed to advance to the boss spawn
@export_range(0, 100) var difficulty_threshold := 10.0
@export var bosses : Array[SpawnObstacleDataHolder]
@export var pickups : Array[SpawnPickupDataHolder]
