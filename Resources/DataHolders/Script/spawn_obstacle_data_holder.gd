class_name SpawnObstacleDataHolder extends Resource

# Variables
@export_category("Base")
##Engine absolute path to desired scene to initialize
@export var scene_directory := ""
##Select type of the obstacle
@export_enum("Gravity", "Static", "Homing", "Other", "Boss") var type:int
##Weigth propability[br][br]
##Determines odds how often given item spawns
@export_range(1, 100) var weight := 1
@export_category("Tags")
##Spawn object left or right sided
@export var flip:bool = false
##Rotation can/cannot be locked during gameplay
@export var can_lock_rotation = false
##All spawn conditions are must be true.[br]
##Otherwise this object cannot spawn.[br][br]
##Example:[br]check1 = true check2 = true check3 = true ---> can[br]
##But:[br]check1 = true check2 = false check3 = true ---> can't
@export var spawner_is_empty = false
##Obstacle requires teleportation position state
@export var tele_state = false
## Obstacle index in ObstacleSpawner internal array
var spawner_index = 0
