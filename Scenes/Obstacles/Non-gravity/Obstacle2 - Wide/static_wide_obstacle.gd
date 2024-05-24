extends ObstacleNonverticalBase

# Methods
func _physics_process(delta):
	super._physics_process(delta)
	if start_attack:
		sprite.position.x = lerp(sprite.position.x, shadow.position.x, delta * 50)
