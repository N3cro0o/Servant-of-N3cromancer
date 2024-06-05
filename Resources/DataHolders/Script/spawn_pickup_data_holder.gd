class_name SpawnPickupDataHolder extends Resource

const BASE_SCRIPT = preload("res://Scenes/PowerUpsAndPickUps/Base/pick_up_logic.gd")
const BASE_IMAGE = "res://Images/icon.svg"

@export var name := ""
@export var image_dir : String = BASE_IMAGE
@export var type : PickUpBase.pickup_type_enum = 0
@export var falling_speed : int = 150
@export var action_logic : Script = BASE_SCRIPT
@export var weight : int = 1
