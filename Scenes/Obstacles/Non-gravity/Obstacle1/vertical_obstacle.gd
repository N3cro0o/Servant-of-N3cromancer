class_name ObstacleNonverticalBase extends ObstacleGravityBase

# Variables
@export var speed := 35.0
@onready var sprite := $SpriteMain
@onready var shadow := $SpriteShadow
var start_attack := false

# Signals

# Methods
func _physics_process(delta):
	position.y += speed * delta

func _on_body_entered(body):
	if body.is_in_group("mainbody"):
		start_attack = true
