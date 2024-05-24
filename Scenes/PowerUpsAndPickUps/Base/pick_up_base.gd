class_name PickUpBase extends RigidBody2D

const debug_string = "[hint=%s]%s[/hint]"
#region Variables
## Used for some specific obstacle variables
@export var spawn_data : SpawnPickupDataHolder:
	set(dat):
		spawn_data = dat
		print_rich(debug_string% [name, "Data updated"])
		if !dat == null:
			update_parms()
		else:
			# If data is empty, replace name to generic one and reset action logic
			name = "PickUpBase"
			var sc = load("res://Scenes/PowerUpsAndPickUps/Base/pick_up_logic.gd")
			action.set_script(sc)
@export_range(1, 1000) var weight := 1
@onready var coll_shape := $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var action : PickUpLogicTemplate = $ActionBlock
var loaded = false
var fall_speed := 0
var collision_radius :float:
	set(i):
		collision_radius = i
		coll_shape.shape.radius = i
#endregion

#region Methods
func update_parms():
	if !loaded:
		return
	# Strings
	name = spawn_data.name
	# Texture
	var spr = load(spawn_data.image_dir)
	sprite.texture = spr
	# Logic
	fall_speed = spawn_data.falling_speed
	action.set_script(spawn_data.action_logic)
	weight = spawn_data.weight

func _ready():
	if not Engine.is_editor_hint():
		coll_shape.shape.radius = collision_radius
	loaded = true

func on_hit_activate():
	print_rich(debug_string % [name, "Picked Up!"])
	action._do_action()
	queue_free()
#endregion
