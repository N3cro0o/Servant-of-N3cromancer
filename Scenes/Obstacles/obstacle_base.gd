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
## Variable saved during initialisation in ObstacleSpawner
var player_body : PlayerLine1
var timer := 0.0
var hit := false
var velocity := Vector2.ZERO
var can_move := true

# Methods
func add_start_velocity(velocity_vec:Vector2, angle:float):
	var vec = velocity_vec.rotated(angle)
	vec.x *= 45 * start_angle_multi
	linear_velocity += vec

func on_mouse_hit():
	hit = true

func _ready():
	pass

func repulse(strength:int):
	var norm_vec : Vector2 = (player_body.return_body_position() - position)
	norm_vec = norm_vec.normalized()
	apply_impulse(norm_vec * strength * -10)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		GameScene.instance.on_obstacle_remove(self)
		pass
