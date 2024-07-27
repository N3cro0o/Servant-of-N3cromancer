class_name ObstacleNonverticalBase extends ObstacleGravityBase

# Variables
@export var speed := 35.0
@onready var sprite := $SpriteMain
@onready var shadow := $SpriteShadow
var start_attack := false

# Signals

# Methods
func _physics_process(delta):
	if can_move:
		position.y += speed * delta * GameScene.speed_multi

func _on_body_entered(body):
	if body.is_in_group("mainbody") and !start_attack:
		start_attack = true
