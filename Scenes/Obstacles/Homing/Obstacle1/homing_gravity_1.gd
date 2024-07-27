extends ObstacleGravityBase

# Variables
@export var speed : int = 200
@export_range(0, 1) var rotation_speed : float = 1.5
@onready var velocity_vec = Vector2.UP * speed
@onready var bum_timer = $BumTimer
@onready var ball_sprite = $FireBallSprite
var move_vector = Vector2(0,-1)
var can_calc_rotation = true
var mouse_hit_check = false
var super_lock_rotation := false
# Signals

# Methods
func _init():
	rotation = PI

func _process(delta):
	# Boom boom check
	if body_hit:
		queue_free()
	# Override lock rotation to true
	if super_lock_rotation:
		lock_rotation = true
	# Random sprite vibration - seems sus
	var x = randi_range(-1, 1)
	var y = randi_range(-1, 1)
	ball_sprite.position = Vector2(x, y)
	# Homing
	if player_body != null:
		move_vector = player_body.return_body_position()
		move_vector = position - move_vector
		move_vector = move_vector.normalized()
	# Find which way to rotate
	if !lock_rotation:
		rotation = rotate_toward(rotation, move_vector.angle() - PI/2, delta * rotation_speed)
	# Movement
	if can_move:
		position += velocity_vec.rotated(rotation) * delta

func repulse(strength:int):
	can_move = false
	super_lock_rotation = true
	set_deferred("lock_rotation", true)
	call_deferred("repulse_help", strength)
	#super.call_deferred("repulse", strength) ----> perpetuum debile

func repulse_help(strength:int):
	rotation = move_vector.angle() + PI/2
	super.repulse(strength)

func on_mouse_hit():
	super.on_mouse_hit()
	if !mouse_hit_check:
		bum_timer.start(7)
		mouse_hit_check = true

func _on_bum_timer_timeout():
	queue_free()
