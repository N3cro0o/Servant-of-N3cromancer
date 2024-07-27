class_name EndlessEnemyStageData extends Resource

@export_group("Obstacles")
@export var left : Array[SpawnObstacleDataHolder]
@export var center : Array[SpawnObstacleDataHolder]
@export var right : Array[SpawnObstacleDataHolder]
@export_group("")
## Difficulty needed to advance to the boss spawn
@export_range(0, 100) var difficulty_threshold := 10.0
@export var bosses : Array[SpawnObstacleDataHolder]
@export var pickups : Array[SpawnPickupDataHolder]
