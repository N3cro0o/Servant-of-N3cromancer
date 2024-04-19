class_name ObstacleGravityBase extends RigidBody2D

# Variables
@export var start_angle_multi := 1.0
@export_range(1, 1000) var weight := 1 ## Determines spawn probability, the higher the better chances
var hit := false
# Signals

# Methods
func add_start_velocity(velocity_vec:Vector2, angle:float):
	var vec = velocity_vec.rotated(angle)
	vec.x *= 45 * start_angle_multi
	linear_velocity += vec
	print(vec)

func on_mouse_hit():
	hit = true
