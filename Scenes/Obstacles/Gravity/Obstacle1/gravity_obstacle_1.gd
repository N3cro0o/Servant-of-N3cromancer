class_name GravityObstacle1 extends ObstacleGravityBase
#region Variables

@onready var label = $Label

#endregion
#region Signals

#endregion

# Basic Godot functions
func _init():
	#start_layer = collision_layer
	var f = randf()
	if f > .5:
		angular_velocity = -angular_velocity

func _physics_process(delta):
	super._physics_process(delta)
	var vel = linear_velocity.distance_to(Vector2.ZERO)
	label.text = str(round(vel))
	label.text += "\nX-%d\nY-%d" %[linear_velocity.x, linear_velocity.y]

# On something functions
func on_mouse_hit():
	super()
	set_collision_layer_value(4, true)
	set_collision_mask_value(4, true)
