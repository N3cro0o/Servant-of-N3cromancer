class_name PickUpBase extends RigidBody2D

const debug_string = "[hint=%s]%s[/hint]"

#region Enums

enum pickup_type_enum
{
	Coin = 0,
	Scroll = 1
}

#endregion
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
@export var type : pickup_type_enum = pickup_type_enum.Coin:
	set(typ):
		type = typ
		match typ:
			pickup_type_enum.Coin:
				bg_sprite.visible = false
			pickup_type_enum.Scroll:
				bg_sprite.visible = true
				sprite.scale = Vector2(0.825, 0.825)
				sprite.position = Vector2(-5, 15)
@export_range(1, 1000) var weight := 1
@onready var coll_shape := $CollisionShape2D
@onready var sprite : Sprite2D = $MainSprite
@onready var bg_sprite = $BGSprite
@onready var action : PickUpLogicTemplate = $ActionBlock
var actual_velocity
var loaded = false
var fall_speed := 0
var collision_radius :float:
	set(i):
		collision_radius = i
		coll_shape.shape.radius = i
		
#endregion

# Basic Godot functions
func _ready():
	if not Engine.is_editor_hint():
		coll_shape.shape.radius = collision_radius
	actual_velocity = linear_velocity
	GmM.on_paused.connect(on_paused)
	loaded = true

# Pickup logic functions
func update_parms():
	if !loaded:
		return
	# Strings & enums
	name = spawn_data.name
	type = spawn_data.type
	# Texture
	var spr = load(spawn_data.image_dir)
	sprite.texture = spr
	# Logic
	fall_speed = spawn_data.falling_speed
	action.set_script(spawn_data.action_logic)
	weight = spawn_data.weight

func on_hit_activate():
	print_rich(debug_string % [name, "Picked Up!"])
	action._do_action()
	queue_free()

# Paused functions
func on_paused(paused):
	if paused:
		# Zero velocity to... idk keep pickups only accesable during normal gameplay
		linear_velocity = Vector2.ZERO
	else:
		linear_velocity = actual_velocity
#endregion
