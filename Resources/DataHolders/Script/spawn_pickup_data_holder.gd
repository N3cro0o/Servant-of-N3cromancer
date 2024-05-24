class_name SpawnPickupDataHolder extends Resource

const BASE_SCRIPT = preload("res://Scenes/PowerUpsAndPickUps/Base/pick_up_logic.gd")

@export var name := ""
@export var image_dir : String = resource_path
@export var falling_speed : int = 150
@export var action_logic : Script = BASE_SCRIPT
@export var weight : int = 1
