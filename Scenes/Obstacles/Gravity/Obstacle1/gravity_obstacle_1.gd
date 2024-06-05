extends ObstacleGravityBase
# Variables
@onready var label = $Label

# Signals

# Methods
func _init():
	var f = randf()
	if f > .5:
		angular_velocity = -angular_velocity

func _physics_process(_delta):
	var vel = linear_velocity.distance_to(Vector2.ZERO)
	label.text = str(round(vel))
	label.text += "\nX-%d\nY-%d" %[linear_velocity.x, linear_velocity.y]

func on_mouse_hit():
	super()
	set_collision_layer_value(4, true)
	set_collision_mask_value(4, true)