extends ObstacleGravityBase
# Variables

# Signals

# Methods

func on_mouse_hit():
	super()
	set_collision_layer_value(4, true)
	set_collision_mask_value(4, true)
