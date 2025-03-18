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
##Obstacle ID. [code]ID[/code] = 0 is recognised as unnasigned
var obstacle_id: int
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
var lock_y_velocity = false
var unpaused_vel := Vector2.ZERO
var start_gravity
#endregion

# Basic Godot functions
func _ready():
	# Subscrive to GmM and instantly check
	GmM.on_paused.connect(on_paused)
	on_paused(GmM.paused)
	
	start_layer = collision_layer
	if grace_period > 0:
		collision_layer = 0
		grace_check = true
		if get_node_or_null("CollisionShape2D") != null:
			$CollisionShape2D.set_deferred("disabled", true)
	
	# Save gravity force for later use
	start_gravity = gravity_scale

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
	# First, update y velocity if needed, then update gravity and lastly save unpaused, unmodified velocity
	if lock_y_velocity && !GmM.paused:
		linear_velocity.y = unpaused_vel.y
	gravity_black_magic()
	# Save pre paused velocity to reuse after unpausing
	if !GmM.paused && !lock_y_velocity:
		unpaused_vel = linear_velocity

func _notification(what):
	# Before deletion logic
	if what == NOTIFICATION_PREDELETE and GameScene.instance != null:
		TsM.obstacle_listener(obstacle_id)
		GameScene.instance.on_obstacle_remove(self)

# Velocity functions
func add_start_velocity(velocity_vec:Vector2, angle:float):
	var vec = velocity_vec.rotated(angle)
	vec.x *= 45 * start_angle_multi
	linear_velocity += vec
	unpaused_vel = linear_velocity

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

# Gravity functions
func gravity_black_magic():
	if GmM.game_speed * start_gravity < gravity_scale && !GmM.paused:
		lock_y_velocity = true
		linear_velocity = unpaused_vel * GmM.game_speed
	else:
		lock_y_velocity = false
	# Gravity scale update
	if !GmM.paused:
		gravity_scale = GmM.game_speed * start_gravity
	else:
		gravity_scale = GmM.paused_slowdown

# On something functions
func on_mouse_hit():
	mouse_hit = true

# Setter 101 XD 
func on_body_hit(b):
	body_hit = b

func on_paused(paused):
	if paused:
		linear_velocity = unpaused_vel * GmM.paused_slowdown / GmM.real_game_speed
	else:
		if lock_y_velocity:
			linear_velocity = unpaused_vel * GmM.game_speed
		else:
			linear_velocity = unpaused_vel

# Scrolls functions
func repulse(strength:int):
	var norm_vec : Vector2 = (player_body.return_body_position() - position)
	norm_vec = norm_vec.normalized()
	apply_impulse(norm_vec * strength * -10)
