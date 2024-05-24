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
# Signals

# Methods
func _init():
	rotation = PI

func _ready():
	#add_start_velocity(Vector2(0, -200), 0)
	pass

func _process(delta):
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
	position += velocity_vec.rotated(rotation) * delta

func on_mouse_hit():
	super.on_mouse_hit()
	if !mouse_hit_check:
		bum_timer.start(7)
		mouse_hit_check = true

func _on_bum_timer_timeout():
	queue_free()
