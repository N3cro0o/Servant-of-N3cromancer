class_name SpawnObstacleDataHolder extends Resource

# Const data

# Variables
## Engine absolute path to desired scene to initialize
@export var scene_directory := ""

## Select type of the obstacle[br][br]
@export_enum("Gravity", "Static") var type:int

## Weigth propability[br][br]
## Determines odds how often given item spawns
@export_range(1, 100) var weight := 1
