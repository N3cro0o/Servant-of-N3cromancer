extends ObstacleGravityBase

# Variables
@export var speed := 35.0
# Signals

# Methods
func _physics_process(delta):
	position.y += speed * delta
