class_name ObstacleNonverticalBase extends ObstacleGravityBase

# Variables
@export var speed := 250.0
@export var use_rotation = false
var spawn_rotation
var sprite #:= $SpriteMain
var shadow #:= $SpriteShadow
var start_attack := false
var speed_vector = Vector2.RIGHT

# Signals

# Methods
func _ready():
	super._ready()
	sprite = get_node_or_null("SpriteMain")
	shadow = get_node_or_null("SpriteShadow")

func add_start_velocity(_velocity_vec:Vector2, angle:float):
	spawn_rotation = angle
	if use_rotation:
		rotation = spawn_rotation + PI

func _physics_process(delta):
	var sin_var = sin(rotation + PI/2)
	var cos_var = cos(rotation + PI/2)
	speed_vector = Vector2(cos_var, sin_var) * speed
	if can_move:
		position += speed_vector * delta * GameScene.speed_multi

func _on_body_entered(body):
	if body.is_in_group("mainbody") and !start_attack:
		start_attack = true
