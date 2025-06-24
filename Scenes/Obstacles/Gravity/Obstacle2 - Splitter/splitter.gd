class_name ObstacleNonverticalSplitter extends ObstacleNonverticalBase

const CHILD_OBSTACLE = preload("res://Scenes/Obstacles/Gravity/Obstacle2 - Splitter/splitter_child.tscn")

#region Variables

@export_range(100, 1000) var child_speed = 750.0
@export_range(0, 45) var child_spread = 15.0
@export_range(0, 5) var child_random_spread = 1.5

#endregion 

# Basic Godot functions
func _ready():
	super._ready()

# On something functions
func on_mouse_hit():
	super.on_mouse_hit()
	call_deferred("split")

# Scrolls functions
func repulse(strength:int):
	lock_delete_logic = true
	set_deferred("freeze", false)
	call_deferred("repulse_help", strength)

func repulse_help(strength:int):
	super.repulse(strength)

# Special logic functions
func split():
	if !lock_delete_logic:
		# Randomization
		var f = randf_range(-child_random_spread, child_random_spread)
		for i in 2:
			# Spawn and properites
			var obs = CHILD_OBSTACLE.instantiate() as ObstacleGravitySplitterChild
			var rotat = spawn_rotation + deg_to_rad(child_spread + f)
			obs.sprite_texture(-child_spread)
			obs.position = position + Vector2(0, -100)
			child_spread *= -1
			var vel = Vector2(0, -child_speed).rotated(rotat)
			obs.unpaused_vel = vel
			obs.player_body = PlayerLine1.instance
			obs.grace_period = 0.2
			obs.grace_check = true
			# Adding to scene
			if GameScene.instance != null:
				GameScene.instance._add_obstacle(obs)
			else:
				get_parent().add_child(obs)
		# Deleting parent object
		queue_free()
