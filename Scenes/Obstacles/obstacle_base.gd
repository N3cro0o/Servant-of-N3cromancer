class_name ObstacleGravityBase extends RigidBody2D

const debug_string = "[hint=%s]%s[/hint]"

# Variables
@export var start_angle_multi := 1.0
## Used for some specific obstacle variables
@export_range(1, 1000) var weight := 1
@export var spawn_data : SpawnObstacleDataHolder
@onready var last_position = position
@export var damage := 1
@export var can_lock_rotation = false
var player_body : PlayerLine1
var timer := 0.0
var hit := false
var velocity := Vector2.ZERO

# Signals

# Methods
func add_start_velocity(velocity_vec:Vector2, angle:float):
	var vec = velocity_vec.rotated(angle)
	vec.x *= 45 * start_angle_multi
	linear_velocity += vec

func on_mouse_hit():
	hit = true
