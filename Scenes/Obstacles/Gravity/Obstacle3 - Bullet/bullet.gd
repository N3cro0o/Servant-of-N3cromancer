class_name ObstacleGravityJumping extends ObstacleGravityBase

const TEXTURE = preload("res://Images/Obstacles/Dart/Wind_bolec.png")

#region Variables
@export_range(0, 1) var screen_fraction = 0.5
var middle_screen
var player_vec : Vector2
var jumped_check = false
var jump_velocity := Vector2(0, -50)

#endregion

# Basic Godot functions
func _ready():
	super._ready()
	# Get percentage of max size
	screen_fraction = 1 - screen_fraction
	middle_screen = get_viewport_rect().size.y * screen_fraction

func _physics_process(delta):
	super._physics_process(delta)
	player_vec = player_body.return_body_position() - position
	if !jumped_check and !mouse_hit:
		rotate(player_vec.angle() - PI/2)
		if position.y >= middle_screen:
			jump()

# Scrolls functions
func jump():
	print("jump")
	$Sprite2D.texture = TEXTURE
	player_vec += jump_velocity
	var vec = player_vec.normalized() * unpaused_vel.length()
	vec.y *= 0.75
	unpaused_vel = vec
	if GmM.paused:
		vec *= GmM.paused_slowdown
	linear_velocity = vec
	jumped_check = true

# On something functions
func on_mouse_hit():
	super.on_mouse_hit()
	$Sprite2D.texture = TEXTURE
