class_name ObstacleHomingFireball extends ObstacleGravityBase

# Variables
@export var speed : int = 200
@export_range(0, 1) var rotation_speed : float = 1.5
@export var sound : SoundHolder
@onready var velocity_vec = Vector2.UP * speed
@onready var bum_timer = $BumTimer
@onready var ball_sprite = $FireBallSprite
@onready var player = $Player
@onready var coll_shape = $CollisionShape2D

var move_vector = Vector2(0,-1)
var can_calc_rotation = true
var mouse_hit_check = false
var super_lock_rotation := false
# Signals

# Methods
func _init():
	rotation = PI

func _ready():
	super._ready()
	# Boom sound
	player.stream = sound.stream
	player.volume_db = sound.volume

func _process(delta):
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

func on_body_hit(b):
	body_hit = b
	player.play()
	coll_shape.set_deferred("disabled", true)
	ball_sprite.visible = false
	speed = 0

func _on_bum_timer_timeout():
	on_sound_end()

func on_sound_end():
	queue_free()
