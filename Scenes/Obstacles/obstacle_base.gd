class_name ObstacleGravityBase extends RigidBody2D

const debug_string = "[hint=%s]%s[/hint]"

#region Variables

@export var start_angle_multi := 1.0
## Used for some specific obstacle variables
@export_range(1, 1000) var weight := 1
@export var spawn_data : SpawnObstacleDataHolder
@export var damage := 1
@export var can_lock_rotation = false
@export_range(0, 5) var grace_period = 0.0
@onready var last_position = position
## Variable saved during initialisation in ObstacleSpawner
var player_body : PlayerLine1
var timer := 0.0
var start_layer
var mouse_hit := false
var body_hit := false:
	set = on_body_hit
var velocity := Vector2.ZERO
var lock_delete_logic := false
var can_move := true
var grace_check = false

#endregion

# Basic Godot functions
func _ready():
	start_layer = collision_layer
	if grace_period > 0:
		collision_layer = 0
		grace_check = true
		if get_node_or_null("CollisionShape2D") != null:
			$CollisionShape2D.set_deferred("disabled", true)

func _physics_process(delta):
	if grace_check:
		if grace_period <= 0:
			grace_check = false
			collision_layer = start_layer
			if get_node_or_null("CollisionShape2D") != null:
				$CollisionShape2D.set_deferred("disabled", false)
			print_rich("[hint=%s]Grace period ended[/hint]" % name)
		elif grace_period > 0:
			grace_period -= delta

func _notification(what):
	# Before deletions logic
	if what == NOTIFICATION_PREDELETE:
		GameScene.instance.on_obstacle_remove(self)

# Velocity functions
func add_start_velocity(velocity_vec:Vector2, angle:float):
	var vec = velocity_vec.rotated(angle)
	vec.x *= 45 * start_angle_multi
	linear_velocity += vec

func add_start_velocity_with_grace(velocity_vec:Vector2, angle:float, grace:float):
	grace_period = grace
	grace_check = true
	add_start_velocity(velocity_vec, angle)

func stop_move():
	set_deferred("lock_rotation", true)
	gravity_scale = 0
	linear_velocity = Vector2.ZERO
	set_deferred("freeze", true)
	set_deferred("can_move", false)

# On something functions
func on_mouse_hit():
	mouse_hit = true

# Setter 101 XD 
func on_body_hit(b):
	body_hit = b

# Scrolls functions
func repulse(strength:int):
	var norm_vec : Vector2 = (player_body.return_body_position() - position)
	norm_vec = norm_vec.normalized()
	apply_impulse(norm_vec * strength * -10)
