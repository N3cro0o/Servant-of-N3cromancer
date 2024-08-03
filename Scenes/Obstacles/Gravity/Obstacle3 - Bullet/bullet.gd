class_name ObstacleGravityJumping extends ObstacleGravityBase

@export_range(0, 1) var screen_fraction = 0.5
var middle_screen
var player_vec : Vector2
var jumped_check = false

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

func jump():
	print("jump")
	player_vec += Vector2(0, -50)
	var vec = player_vec.normalized() * linear_velocity.length()
	vec.y *= 0.75
	linear_velocity = vec
	jumped_check = true
